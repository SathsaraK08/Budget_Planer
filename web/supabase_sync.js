// supabase_sync.js - Cloud persistence layer using anon public key only
const SUPABASE_URL  = "https://bwavzxjyrrbfhuhtwjpt.supabase.co";
const SUPABASE_ANON = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3YXZ6eGp5cnJiZmh1aHR3anB0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc5OTQ2MzYsImV4cCI6MjEwMzU3MDYzNn0.PSrmU84hKH-eF-73DcnB0oZaP6Bt3iwoMCSoRLiUpp0";
const HOUSEHOLD_ID  = "default";
const REST_BASE     = SUPABASE_URL + "/rest/v1";

function sbHeaders(extra) {
  extra = extra || {};
  return Object.assign({ "Content-Type": "application/json", "apikey": SUPABASE_ANON, "Authorization": "Bearer " + SUPABASE_ANON, "Prefer": "return=minimal" }, extra);
}

let syncStatus = "idle";
let saveDebounceTimer = null;

function setSyncStatus(status, message) {
  syncStatus = status;
  const el = document.getElementById("supabase-sync-indicator");
  if (!el) return;
  const icons = { idle: "cloud", syncing: "sync", online: "check", offline: "offline", error: "error" };
  const colors = { idle: "#9CA3AF", syncing: "#F59E0B", online: "#10B981", offline: "#6B7280", error: "#EF4444" };
  const labels = { idle: "☁️", syncing: "🔄", online: "✅", offline: "📴", error: "❌" };
  el.innerHTML = '<span style="color:' + (colors[status]||"#9CA3AF") + ';font-size:0.75rem;font-weight:600;">' + (labels[status]||"?") + ' Supabase ' + (message||status) + '</span>';
}

async function loadFromSupabase() {
  try {
    setSyncStatus("syncing", "loading...");
    const res = await fetch(REST_BASE + "/household_state?household_id=eq." + HOUSEHOLD_ID + "&select=state_json,updated_at&limit=1", { headers: sbHeaders({ "Prefer": "return=representation" }) });
    if (!res.ok) throw new Error("HTTP " + res.status);
    const rows = await res.json();
    if (!rows.length || !rows[0].state_json || Object.keys(rows[0].state_json).length === 0) {
      setSyncStatus("online", "seeding...");
      await saveToSupabase();
      setSyncStatus("online", "seeded");
      return null;
    }
    const cloudTs = new Date(rows[0].updated_at).getTime();
    const localTs = parseInt(localStorage.getItem(STORAGE_KEY + "_timestamp") || "0");
    if (cloudTs > localTs) {
      setSyncStatus("online", "loaded from cloud");
      return rows[0].state_json;
    } else {
      await saveToSupabase();
      setSyncStatus("online", "synced");
      return null;
    }
  } catch (err) {
    console.warn("[Supabase] Load failed:", err.message);
    setSyncStatus("offline", "(offline)");
    return null;
  }
}

async function saveToSupabase(stateOverride) {
  try {
    const stateToSave = stateOverride || state;
    if (!stateToSave) return;
    const res = await fetch(REST_BASE + "/household_state", {
      method: "POST",
      headers: sbHeaders({ "Prefer": "resolution=merge-duplicates,return=minimal" }),
      body: JSON.stringify({ household_id: HOUSEHOLD_ID, state_json: stateToSave, app_version: "5" })
    });
    if (!res.ok) throw new Error("HTTP " + res.status + ": " + await res.text());
    localStorage.setItem(STORAGE_KEY + "_timestamp", Date.now().toString());
    setSyncStatus("online", "saved");
  } catch (err) {
    console.warn("[Supabase] Save failed:", err.message);
    setSyncStatus("offline", "(offline)");
  }
}

function debouncedSaveToSupabase() {
  clearTimeout(saveDebounceTimer);
  setSyncStatus("syncing", "saving...");
  saveDebounceTimer = setTimeout(function() { saveToSupabase(); }, 800);
}

async function saveStateSnapshot(note) {
  note = note || "Manual save";
  try {
    await fetch(REST_BASE + "/household_state_history", { method: "POST", headers: sbHeaders(), body: JSON.stringify({ household_id: HOUSEHOLD_ID, state_json: state, note: note }) });
    showToast("Snapshot saved: " + note, "success");
  } catch (err) { showToast("Could not save snapshot: " + err.message, "danger"); }
}

async function listStateSnapshots() {
  try {
    const res = await fetch(REST_BASE + "/household_state_history?household_id=eq." + HOUSEHOLD_ID + "&select=id,note,saved_at&order=saved_at.desc&limit=20", { headers: sbHeaders({ "Prefer": "return=representation" }) });
    return await res.json();
  } catch (err) { return []; }
}

async function restoreStateSnapshot(snapshotId) {
  try {
    const res = await fetch(REST_BASE + "/household_state_history?id=eq." + snapshotId + "&select=state_json", { headers: sbHeaders({ "Prefer": "return=representation" }) });
    const rows = await res.json();
    if (!rows.length) return showToast("Snapshot not found", "danger");
    const parsed = rows[0].state_json;
    const merged = Object.assign({}, defaultState, parsed, {
      household: Object.assign({}, defaultState.household, parsed.household),
      uiComponents: Object.assign({}, defaultState.uiComponents, parsed.uiComponents),
      uiLabels: Object.assign({}, defaultUiLabels, parsed.uiLabels || {}),
      bnplPlatforms: (parsed.bnplPlatforms && parsed.bnplPlatforms.length) ? parsed.bnplPlatforms : defaultState.bnplPlatforms,
      wishlistCategories: (parsed.wishlistCategories && parsed.wishlistCategories.length) ? parsed.wishlistCategories : defaultState.wishlistCategories
    });
    Object.keys(merged).forEach(function(k) { state[k] = merged[k]; });
    persistState();
    renderApp();
    showToast("Snapshot restored!", "success");
  } catch (err) { showToast("Restore failed: " + err.message, "danger"); }
}

async function testSupabaseConnection() {
  const el = document.getElementById("supabase-test-output");
  if (el) el.innerHTML = "<em>Testing connection to Supabase...</em>";
  try {
    const start = Date.now();
    const res = await fetch(REST_BASE + "/household_state?household_id=eq." + HOUSEHOLD_ID + "&select=household_id,updated_at&limit=1", { headers: sbHeaders({ "Prefer": "return=representation" }) });
    const latency = Date.now() - start;
    const rows = await res.json();
    const rowInfo = rows.length > 0 ? ("Yes — last updated: " + rows[0].updated_at) : "No rows yet — run the SQL schema first!";
    if (el) el.innerHTML = '<span style="color:var(--success);">Connected to Supabase (' + latency + 'ms)</span><br><small>Row found: ' + rowInfo + '</small>';
    setSyncStatus("online", latency + "ms");
  } catch (err) {
    if (el) el.innerHTML = '<span style="color:var(--danger);">Failed: ' + err.message + '</span>';
    setSyncStatus("error", "failed");
  }
}

async function openSnapshotsModal() {
  const snapshots = await listStateSnapshots();
  var rows = snapshots.length === 0
    ? '<p class="text-muted" style="text-align:center;padding:1rem;">No snapshots yet.</p>'
    : snapshots.map(function(s) {
        return '<div class="spend-row"><div style="flex:1;"><div style="font-weight:600;font-size:0.85rem;">' + (s.note || 'Unnamed') + '</div><div style="font-size:0.75rem;color:var(--text-muted);">' + new Date(s.saved_at).toLocaleString() + '</div></div><button class="btn btn-secondary btn-sm" onclick="restoreStateSnapshot(\'' + s.id + '\');closeModal();">Restore</button></div>';
      }).join('');
  var html = '<div class="explainer-box" style="margin-bottom:1rem;"><strong>Cloud Snapshots</strong> - Roll back to any saved state.</div>'
    + '<div style="display:flex;gap:0.5rem;margin-bottom:1rem;"><input type="text" id="snapshot-note" class="form-control" placeholder="Label this snapshot..." style="flex:1;"><button class="btn btn-primary btn-sm" onclick="saveStateSnapshot(document.getElementById(\'snapshot-note\').value||\'Manual snapshot\');closeModal();">Save Now</button></div>'
    + rows;
  openModal("Cloud Snapshots & History", html, null);
}
