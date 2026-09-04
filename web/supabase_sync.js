// supabase_sync.js - Cloud persistence layer with Auth integration
const SUPABASE_URL  = "https://bwavzxjyrrbfhuhtwjpt.supabase.co";
const SUPABASE_ANON = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3YXZ6eGp5cnJiZmh1aHR3anB0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc5OTQ2MzYsImV4cCI6MjEwMzU3MDYzNn0.PSrmU84hKH-eF-73DcnB0oZaP6Bt3iwoMCSoRLiUpp0";
const REST_BASE     = SUPABASE_URL + "/rest/v1";

// Supabase client instance
const _sb = (typeof supabase !== "undefined" && supabase.createClient)
  ? supabase.createClient(SUPABASE_URL, SUPABASE_ANON)
  : null;

let cachedSession = null;

async function getCurrentSession() {
  if (sessionStorage.getItem("demo_auth") === "true") {
    return {
      user: { id: "demo_user", email: "demo@homebudget.lk" },
      access_token: SUPABASE_ANON
    };
  }
  if (!_sb) return null;
  try {
    const { data: { session } } = await _sb.auth.getSession();
    cachedSession = session;
    return session;
  } catch (e) {
    return null;
  }
}

async function getActiveHouseholdId() {
  const session = await getCurrentSession();
  if (session && session.user && session.user.id) {
    return session.user.id;
  }
  return "default";
}

async function sbHeaders(extra) {
  extra = extra || {};
  const session = await getCurrentSession();
  const token = session?.access_token || SUPABASE_ANON;
  return Object.assign({
    "Content-Type": "application/json",
    "apikey": SUPABASE_ANON,
    "Authorization": "Bearer " + token,
    "Prefer": "return=minimal"
  }, extra);
}

async function logoutHousehold() {
  sessionStorage.removeItem("activeSessionMemberId");
  sessionStorage.removeItem("activeSessionMemberName");
  sessionStorage.removeItem("demo_auth");
  if (_sb) {
    await _sb.auth.signOut();
  }
  window.location.href = "auth.html";
}

async function updateAuthHeaderUi() {
  const session = await getCurrentSession();
  const btn = document.getElementById("top-header-logout-btn");
  if (!btn) return;
  if (session) {
    btn.className = "navbar-icon-btn btn-logout";
    btn.title = "Sign out of household";
    btn.onclick = logoutHousehold;
    btn.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
      <polyline points="16 17 21 12 16 7"></polyline>
      <line x1="21" y1="12" x2="9" y2="12"></line>
    </svg>`;
  } else {
    btn.className = "navbar-icon-btn btn-login";
    btn.title = "Sign in to household";
    btn.onclick = function() { window.location.href = "auth.html"; };
    btn.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
      <polyline points="10 17 15 12 10 7"></polyline>
      <line x1="15" y1="12" x2="3" y2="12"></line>
    </svg>`;
  }
}

let syncStatus = "idle";
let saveDebounceTimer = null;

function setSyncStatus(status, message) {
  syncStatus = status;
  const el = document.getElementById("supabase-sync-indicator");
  if (!el) return;
  const colors = { idle: "#9CA3AF", syncing: "#F59E0B", online: "#10B981", offline: "#6B7280", error: "#EF4444" };
  const svgIcons = {
    idle: '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px; margin-right:4px;"><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"></path></svg>',
    syncing: '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px; margin-right:4px; animation: spin 1.2s linear infinite;"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"></path></svg>',
    online: '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px; margin-right:4px;"><polyline points="20 6 9 17 4 12"></polyline></svg>',
    offline: '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px; margin-right:4px;"><line x1="1" y1="1" x2="23" y2="23"></line><path d="M16.72 11.06A10.94 10.94 0 0 1 19 12.55"></path><path d="M5 12.55a10.94 10.94 0 0 1 5.17-2.39"></path><path d="M10.71 5.05A16 16 0 0 1 22.58 9"></path><path d="M1.42 9a15.91 15.91 0 0 1 4.7-2.88"></path><path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path><line x1="12" y1="20" x2="12.01" y2="20"></line></svg>',
    error: '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px; margin-right:4px;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>'
  };
  el.innerHTML = '<span style="color:' + (colors[status]||"#9CA3AF") + ';font-size:0.75rem;font-weight:600;display:inline-flex;align-items:center;">' + (svgIcons[status]||svgIcons.idle) + ' Supabase ' + (message||status) + '</span>';
}

if (typeof document !== "undefined") {
  document.addEventListener("DOMContentLoaded", function() {
    updateAuthHeaderUi();
  });
}

async function loadFromSupabase() {
  try {
    setSyncStatus("syncing", "loading...");
    const householdId = await getActiveHouseholdId();
    const headers = await sbHeaders({ "Prefer": "return=representation" });
    const res = await fetch(REST_BASE + "/household_state?household_id=eq." + householdId + "&select=state_json,updated_at&limit=1", { headers });
    if (!res.ok) throw new Error("HTTP " + res.status);
    const rows = await res.json();
    if (!rows.length || !rows[0].state_json || Object.keys(rows[0].state_json).length === 0) {
      setSyncStatus("online", "ready");
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
    const householdId = await getActiveHouseholdId();
    const headers = await sbHeaders({ "Prefer": "resolution=merge-duplicates,return=minimal" });
    const res = await fetch(REST_BASE + "/household_state", {
      method: "POST",
      headers: headers,
      body: JSON.stringify({ household_id: householdId, state_json: stateToSave, app_version: "6" })
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
    const householdId = await getActiveHouseholdId();
    await fetch(REST_BASE + "/household_state_history", { method: "POST", headers: await sbHeaders(), body: JSON.stringify({ household_id: householdId, state_json: state, note: note }) });
    showToast("Snapshot saved: " + note, "success");
  } catch (err) { showToast("Could not save snapshot: " + err.message, "danger"); }
}

async function listStateSnapshots() {
  try {
    const householdId = await getActiveHouseholdId();
    const headers = await sbHeaders({ "Prefer": "return=representation" });
    const res = await fetch(REST_BASE + "/household_state_history?household_id=eq." + householdId + "&select=id,note,saved_at&order=saved_at.desc&limit=20", { headers });
    return await res.json();
  } catch (err) { return []; }
}

async function restoreStateSnapshot(snapshotId) {
  try {
    const headers = await sbHeaders({ "Prefer": "return=representation" });
    const res = await fetch(REST_BASE + "/household_state_history?id=eq." + snapshotId + "&select=state_json", { headers });
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
    const householdId = await getActiveHouseholdId();
    const headers = await sbHeaders({ "Prefer": "return=representation" });
    const res = await fetch(REST_BASE + "/household_state?household_id=eq." + householdId + "&select=household_id,updated_at&limit=1", { headers });
    const latency = Date.now() - start;
    const rows = await res.json();
    const rowInfo = rows.length > 0 ? ("Yes — last updated: " + rows[0].updated_at) : "No rows yet — ready to save!";
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
