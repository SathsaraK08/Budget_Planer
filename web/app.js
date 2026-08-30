// ==============================================================================
// 100% DETERMINISTIC HOUSEHOLD BUDGET ENGINE & WORDPRESS-GRADE ADMIN CMS v4.5
// ==============================================================================

const STORAGE_KEY = "household_budget_master_db_v5";

const defaultUiLabels = {
  // Navigation
  "nav.dashboard": "Dashboard",
  "nav.completed": "Completed Payments",
  "nav.daily_spends": "Daily Spends",
  "nav.bnpl": "BNPL & Koko",
  "nav.fixed_bills": "Fixed Bills & Loans",
  "nav.forecast": "Survival Forecast",
  "nav.wishlist": "Needs Planner",
  "nav.subscriptions": "Subscriptions",
  "nav.calendar": "Spend Calendar",
  "nav.analytics": "Analytics",

  // Dashboard Page
  "page.dashboard.title": "Cycle Overview",
  "page.dashboard.cycle_badge": "25th-to-25th Cycle",
  "page.dashboard.balance_header": "REALTIME REMAINING SPENDABLE BALANCE",
  "page.dashboard.card_income": "Total Cycle Income",
  "page.dashboard.card_income_sub": "Combined salaries this cycle",
  "page.dashboard.card_committed": "Committed Outgoings",
  "page.dashboard.card_committed_sub": "Rent, Loans, BNPL, CC, Subs",
  "page.dashboard.card_spent": "Daily Spent so far",
  "page.dashboard.card_spent_sub": "Cash & Debit Card",
  "page.dashboard.card_wishlist": "Planned Needs",
  "page.dashboard.card_wishlist_sub": "Allocated for Current Cycle",
  "page.dashboard.breakdown_title": "Cycle Outgoings Breakdown",
  "page.dashboard.breakdown_sub": "Exact breakdown of commitments deducted from your salary",
  "page.dashboard.recent_spends_title": "Recent Daily Spends",
  "page.dashboard.recent_spends_sub": "Itemized cash and card transactions",

  // BNPL Page
  "page.bnpl.title": "BNPL & Koko Plans",
  "page.bnpl.subtitle": "Active installments, remaining balances, and monthly commitments.",
  "page.bnpl.active_heading": "Pending Installments (Current Cycle)",
  "page.bnpl.completed_heading": "Settled BNPL Installments in this Cycle",
  "page.bnpl.btn_add": "➕ Add BNPL Plan",
  "table.bnpl.col.status": "Status",
  "table.bnpl.col.item": "Item Name",
  "table.bnpl.col.platform": "Platform",
  "table.bnpl.col.purchaser": "Purchaser",
  "table.bnpl.col.monthly": "Monthly Due",
  "table.bnpl.col.remaining": "Remaining / Total",
  "table.bnpl.col.actions": "Actions",

  // Fixed Bills Page
  "page.fixed.title": "Fixed Bills & Bank Loans",
  "page.fixed.subtitle": "Mandatory recurring payments due on or around salary day.",
  "page.fixed.active_heading": "Pending Fixed Payments (Current Cycle)",
  "page.fixed.completed_heading": "Settled Fixed Bills in this Cycle",
  "page.fixed.btn_add": "➕ Add Fixed Bill",

  // Needs Planner / Wishlist Page
  "page.wishlist.title": "Needs Planner & Wishlist",
  "page.wishlist.subtitle": "Categorized buy-list and needs planning prioritized for purchase.",
  "page.wishlist.active_heading": "Pending Needs & Items",
  "page.wishlist.completed_heading": "Purchased & Settled Items",
  "page.wishlist.btn_add": "➕ Add Item to Plan",

  // Daily Spends Page
  "page.daily.title": "Daily Expense Logs",
  "page.daily.subtitle": "Track every daily cash, card, and transfer expenditure.",
  "page.daily.btn_add": "➕ Log Spend",

  // Subscriptions Page
  "page.subs.title": "Subscriptions & Recurring Cards",
  "page.subs.subtitle": "Digital services, mobile packages, broadband routers, and cards.",
  "page.subs.btn_add": "➕ Add Subscription",

  // Completed Page
  "page.completed.title": "✅ Completed & Settled Payments",
  "page.completed.subtitle": "Master record of all payments settled in this cycle, organized by originating category.",

  // Forecast Page
  "page.forecast.title": "Forward Survival Forecast",
  "page.forecast.subtitle": "Deterministic forward-looking projection for next month.",

  // Calendar Page
  "nav.calendar": "Spend Calendar",

  // Buttons & Global
  "btn.log_spend": "Log Daily Spend",
  "btn.admin_cms": "Admin CMS",
  "btn.how_it_works": "❓ How It Works",
  "btn.refresh_charts": "🔄 Refresh Charts"
};

const defaultState = {
  household: {
    name: "HomeBudget",
    tagline: "25th-to-25th Cycle Tracker",
    logo: "💰",
    currency: "Rs.",
    currencyCode: "LKR",
    cycleStartDay: 25,
    themePreset: "theme-emerald",
    customCss: ""
  },
  adminProfile: {
    name: "Admin",
    email: "admin@homebudget.lk",
    role: "Administrator",
    avatar: "A"
  },
  uiComponents: {
    showBalanceCard: true,
    showAiAdvisorCard: true,
    showMetricsGrid: true,
    showBreakdownTable: true,
    showRecentSpends: true,
    showQuickSpendBtn: true,
    showForecastBanner: true,
    showWishlistSection: true
  },
  uiLabels: { ...defaultUiLabels },
  // Dynamic lookup tables — configuration only (not personal data)
  bnplPlatforms: [
    { id: "bp_1", name: "Koko", color: "#F59E0B" },
    { id: "bp_2", name: "Mintpay", color: "#6366F1" },
    { id: "bp_3", name: "PayZy", color: "#EC4899" }
  ],
  fixedBillCategories: [
    { id: "fc_1", name: "Housing" },
    { id: "fc_2", name: "Utilities" },
    { id: "fc_3", name: "Loan" },
    { id: "fc_4", name: "Insurance" },
    { id: "fc_5", name: "Telecom" },
    { id: "fc_6", name: "Other Fixed" }
  ],
  wishlistCategories: [
    { id: "wc_1", name: "Home Needs", sortOrder: 1 },
    { id: "wc_2", name: "My Needs", sortOrder: 2 },
    { id: "wc_3", name: "Partner Needs", sortOrder: 3 },
    { id: "wc_4", name: "Kitchen", sortOrder: 4 },
    { id: "wc_5", name: "Bathroom", sortOrder: 5 },
    { id: "wc_6", name: "Tech & Gadgets", sortOrder: 6 }
  ],
  cycleHistory: [],
  categories: [
    { id: "cat_1", name: "Groceries", color: "#10B981", monthlyBudget: 45000 },
    { id: "cat_2", name: "Transport", color: "#F59E0B", monthlyBudget: 15000 },
    { id: "cat_3", name: "Food & Dining", color: "#EC4899", monthlyBudget: 25000 },
    { id: "cat_4", name: "Personal Care", color: "#8B5CF6", monthlyBudget: 8000 },
    { id: "cat_5", name: "Health & Gym", color: "#06B6D4", monthlyBudget: 6000 },
    { id: "cat_6", name: "Other", color: "#64748B", monthlyBudget: 30000 }
  ],
  paymentMethods: [
    { id: "pm_1", name: "Cash", type: "cash" },
    { id: "pm_2", name: "Debit Card", type: "card" },
    { id: "pm_3", name: "Credit Card", type: "card" },
    { id: "pm_4", name: "Bank Transfer", type: "bank" }
  ],
  // AI key is set only through Admin CMS → AI Advisor Studio — never hardcoded here
  aiSettings: {
    provider: "gemini",
    geminiKey: "",
    openaiKey: "",
    model: "gemini-2.0-flash",
    tone: "balanced",
    customPromptTemplate: ""
  },
  forecastSettings: {
    reservePercentage: 5.0,
    survivalBufferDays: 30,
    committedCategories: ["Housing", "Utilities", "Loan", "Insurance", "Telecom"]
  },
  // Personal data — starts EMPTY. Use Admin CMS or onboarding wizard to populate.
  members: [],
  activeCycle: {
    name: "",
    daysRemaining: 30
  },
  incomes: [],
  fixedPayments: [],
  subscriptions: [],
  creditCards: [],
  installments: [],
  wishlist: [],
  dailySpends: []
};

// State initialization
let state = loadSavedState();

function loadSavedState() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      const parsed = JSON.parse(saved);
      return { 
        ...defaultState, 
        ...parsed, 
        household: { ...defaultState.household, ...parsed.household },
        uiComponents: { ...defaultState.uiComponents, ...parsed.uiComponents },
        uiLabels: { ...defaultUiLabels, ...(parsed.uiLabels || {}) },
        forecastSettings: { ...defaultState.forecastSettings, ...parsed.forecastSettings },
        bnplPlatforms: parsed.bnplPlatforms && parsed.bnplPlatforms.length ? parsed.bnplPlatforms : defaultState.bnplPlatforms,
        fixedBillCategories: parsed.fixedBillCategories && parsed.fixedBillCategories.length ? parsed.fixedBillCategories : defaultState.fixedBillCategories,
        wishlistCategories: parsed.wishlistCategories && parsed.wishlistCategories.length ? parsed.wishlistCategories : defaultState.wishlistCategories,
        cycleHistory: parsed.cycleHistory && parsed.cycleHistory.length ? parsed.cycleHistory : defaultState.cycleHistory
      };
    }
  } catch (e) {
    console.error("Failed to load state", e);
  }
  return JSON.parse(JSON.stringify(defaultState));
}

function persistState() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    // Also push to Supabase cloud (debounced — won't flood the API)
    if (typeof debouncedSaveToSupabase === "function") {
      debouncedSaveToSupabase();
    }
  } catch (e) {
    console.error("Failed to save state", e);
  }
}

// Label Lookup Helper
function getLabel(key, fallback = "") {
  if (state.uiLabels && state.uiLabels[key] !== undefined && state.uiLabels[key] !== "") {
    return state.uiLabels[key];
  }
  return defaultUiLabels[key] || fallback;
}

// Formatter
function fmt(val) {
  const sym = state.household?.currency || "Rs.";
  const num = (Number(val) || 0).toLocaleString("en-US", { maximumFractionDigits: 0 });
  return `${sym} ${num}`;
}

// Toast
function showToast(message, type = "info") {
  let container = document.getElementById("toast-container");
  if (!container) {
    container = document.createElement("div");
    container.id = "toast-container";
    container.className = "toast-container";
    document.body.appendChild(container);
  }
  const toast = document.createElement("div");
  toast.className = `toast toast-${type}`;
  toast.innerHTML = `<span>${type === "success" ? "✅" : type === "danger" ? "⚠️" : "ℹ️"}</span> <span>${message}</span>`;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = "0";
    toast.style.transform = "translateY(10px)";
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}

// Deterministic Calculation Engine
function calculateMetrics() {
  const totalIncome = (state.incomes || []).reduce((acc, i) => acc + (Number(i.amount) || 0), 0);
  const totalFixed = (state.fixedPayments || []).reduce((acc, f) => acc + (Number(f.amount) || 0), 0);
  const totalInstallments = (state.installments || []).reduce((acc, inst) => acc + (Number(inst.monthly) || 0), 0);
  const totalCreditCards = (state.creditCards || []).reduce((acc, c) => acc + (Number(c.due) || 0), 0);
  const totalSubscriptions = (state.subscriptions || []).reduce((acc, s) => acc + (Number(s.amountLkr) || 0), 0);

  const totalCommitted = totalFixed + totalInstallments + totalCreditCards + totalSubscriptions;

  let totalCash = 0;
  let totalCard = 0;
  for (const s of (state.dailySpends || [])) {
    const amt = Number(s.amount) || 0;
    if ((s.method || "").toLowerCase().includes("cash")) {
      totalCash += amt;
    } else {
      totalCard += amt;
    }
  }
  const totalDailySpent = totalCash + totalCard;

  const totalPlannedWishlist = (state.wishlist || [])
    .filter(w => w.isPlanned)
    .reduce((acc, w) => acc + (Number(w.cost) || 0), 0);

  const remainingBalance = totalIncome - (totalCommitted + totalDailySpent);
  const projectedSavings = remainingBalance - totalPlannedWishlist;

  const settledFixed = (state.fixedPayments || []).filter(f => f.isPaid).reduce((acc, f) => acc + (Number(f.amount) || 0), 0);
  const settledBnpl = (state.installments || []).filter(i => i.isPaid).reduce((acc, i) => acc + (Number(i.monthly) || 0), 0);
  const settledCards = (state.creditCards || []).filter(c => c.isPaid).reduce((acc, c) => acc + (Number(c.due) || 0), 0);
  const settledSubs = (state.subscriptions || []).filter(s => s.isPaid).reduce((acc, s) => acc + (Number(s.amountLkr) || 0), 0);
  const settledSpends = totalDailySpent;
  const totalSettledAmount = settledFixed + settledBnpl + settledCards + settledSubs + settledSpends;
  const totalPendingAmount = (totalCommitted + totalDailySpent) - totalSettledAmount;

  const nextEstimatedIncome = totalIncome;
  const nextEstimatedCommitted = totalFixed + totalSubscriptions + (totalCreditCards > 0 ? 10000 : 0) +
    (state.installments || []).filter(inst => (inst.remaining || 0) > (inst.monthly || 0)).reduce((acc, inst) => acc + (Number(inst.monthly) || 0), 0);
  const nextNetSurplus = nextEstimatedIncome - nextEstimatedCommitted;
  const hasShortfall = nextNetSurplus < 0;
  const reservePct = state.forecastSettings?.reservePercentage || 5.0;
  const safetyReserveAmount = nextEstimatedIncome * (reservePct / 100);
  const requiredSurvivalBuffer = hasShortfall ? Math.abs(nextNetSurplus) + safetyReserveAmount : safetyReserveAmount;

  return {
    totalIncome,
    totalFixed,
    totalInstallments,
    totalCreditCards,
    totalSubscriptions,
    totalCommitted,
    totalCash,
    totalCard,
    totalDailySpent,
    totalPlannedWishlist,
    remainingBalance,
    projectedSavings,
    settledFixed,
    settledBnpl,
    settledCards,
    settledSubs,
    settledSpends,
    totalSettledAmount,
    totalPendingAmount,
    nextEstimatedIncome,
    nextEstimatedCommitted,
    nextNetSurplus,
    hasShortfall,
    reservePct,
    safetyReserveAmount,
    requiredSurvivalBuffer
  };
}

// Modal Engine
let currentModalSaveCallback = null;
function openModal(title, bodyHtml, onSave) {
  const modal = document.getElementById("generic-modal");
  if (!modal) return;
  document.getElementById("generic-modal-title").textContent = title;
  document.getElementById("generic-modal-body").innerHTML = bodyHtml;
  currentModalSaveCallback = onSave;
  modal.classList.add("active");
}
function closeModal() {
  const modal = document.getElementById("generic-modal");
  if (modal) modal.classList.remove("active");
  currentModalSaveCallback = null;
}
function handleModalSave() {
  if (typeof currentModalSaveCallback === "function") {
    currentModalSaveCallback();
  }
}

function customConfirm(message, onConfirm) {
  const html = `
    <div style="padding: 0.5rem 0;">
      <p style="font-size: 1rem; color: #F3F4F6; margin-bottom: 1rem;">${message}</p>
      <p style="font-size: 0.8rem; color: var(--text-muted);">This action updates your household database immediately.</p>
    </div>
  `;
  openModal("Confirm Action", html, () => {
    closeModal();
    onConfirm();
  });
}

// Payment Ticking Action
function togglePaymentStatus(type, id) {
  let item = null;
  let label = "Payment";

  if (type === 'fixed') {
    item = (state.fixedPayments || []).find(x => x.id === id);
    label = item ? item.name : "Fixed bill";
  } else if (type === 'bnpl') {
    item = (state.installments || []).find(x => x.id === id);
    label = item ? item.item : "BNPL plan";
  } else if (type === 'sub') {
    item = (state.subscriptions || []).find(x => x.id === id);
    label = item ? item.name : "Subscription";
  } else if (type === 'card') {
    item = (state.creditCards || []).find(x => x.id === id);
    label = item ? item.name : "Credit card";
  } else if (type === 'wishlist') {
    item = (state.wishlist || []).find(x => x.id === id);
    label = item ? item.item : "Wishlist item";
  }

  if (item) {
    item.isPaid = !item.isPaid;
    item.paidDate = item.isPaid ? new Date().toISOString().split("T")[0] : null;
    persistState();
    renderApp();
    if (item.isPaid) {
      showToast(`✅ Marked as PAID: ${label}! Moved to Completed list.`, "success");
    } else {
      showToast(`↩️ Marked as UNPAID: ${label}`, "info");
    }
  }
}

// --- LABELS & TEXT CMS MANAGEMENT ---
function saveAllUiLabels() {
  document.querySelectorAll(".cms-label-input").forEach(input => {
    const key = input.dataset.labelKey;
    if (key) {
      state.uiLabels[key] = input.value.trim();
    }
  });
  persistState();
  renderApp();
  showToast("All UI labels saved live with zero redeploy!", "success");
}

function resetAllUiLabels() {
  customConfirm("Reset all labels and text back to system defaults?", () => {
    state.uiLabels = { ...defaultUiLabels };
    persistState();
    renderApp();
    renderLabelsCmsScreen();
    showToast("UI labels reset to defaults", "info");
  });
}

function filterLabelsCms(query) {
  const q = (query || "").toLowerCase();
  document.querySelectorAll(".label-edit-row").forEach(row => {
    const key = (row.dataset.key || "").toLowerCase();
    const val = (row.querySelector("input")?.value || "").toLowerCase();
    row.style.display = (key.includes(q) || val.includes(q)) ? "" : "none";
  });
}

function renderLabelsCmsScreen() {
  const container = document.getElementById("cms-labels-container");
  if (!container) return;

  const entries = Object.keys(defaultUiLabels);
  container.innerHTML = `
    <div style="margin-bottom: 1.25rem; display: flex; gap: 0.75rem; align-items: center;">
      <input type="text" id="cms-labels-search" class="form-control" placeholder="🔍 Search label key or text (e.g. bnpl, title, column)..." oninput="filterLabelsCms(this.value)">
      <button class="btn btn-primary" onclick="saveAllUiLabels()">💾 Save All Labels</button>
      <button class="btn btn-secondary" onclick="resetAllUiLabels()">🔄 Reset Defaults</button>
    </div>

    <div class="table-responsive">
      <table class="cms-table">
        <thead>
          <tr>
            <th style="width: 35%;">Label Key (Stable ID)</th>
            <th style="width: 25%;">Default Value</th>
            <th style="width: 40%;">Current Live Text (Editable)</th>
          </tr>
        </thead>
        <tbody>
          ${entries.map(key => {
            const defVal = defaultUiLabels[key];
            const currVal = getLabel(key, defVal);
            return `
              <tr class="label-edit-row" data-key="${key}">
                <td><code style="color: #A5B4FC; font-size: 0.8rem;">${key}</code></td>
                <td><small style="color: var(--text-muted);">${defVal}</small></td>
                <td>
                  <input type="text" class="form-control cms-label-input" data-label-key="${key}" value="${currVal}">
                </td>
              </tr>
            `;
          }).join("")}
        </tbody>
      </table>
    </div>
  `;
}

// Help Guide
const HELP_TOPICS = {
  cycle: {
    title: "📅 The 25th-to-25th Salary Cycle",
    content: `<p>Aligns metrics directly with your <strong>25th-to-25th salary window</strong> so you always know your exact spendable cash until next payday.</p>`
  },
  balance: {
    title: "💰 Realtime Remaining Spendable Balance",
    content: `<p><strong>Formula:</strong> Spendable Balance = Total Salary - Committed Fixed Bills - Daily Spends</p>`
  },
  forecast: {
    title: "📐 Forward Survival Forecasting & Safety Reserve",
    content: `<p>Predicts next month's financial health before next month starts and calculates the exact safety buffer to keep.</p>`
  },
  bnpl: {
    title: "🛍️ BNPL & Installment Tracking",
    content: `<p>When an installment plan reaches 3/3 paid installments, it automatically terminates and frees up cashflow.</p>`
  },
  completed: {
    title: "✅ Completed Payments & Tracking",
    content: `<p>Whenever you make a payment, click the <strong>Mark as Paid</strong> button. The item animates with a crossed line and moves into the <strong>Completed Payments</strong> register organized by category!</p>`
  },
  cms: {
    title: "👑 WordPress-Grade Admin CMS Control",
    content: `<p>Rename any page title, table header, button label, or theme with zero code redeploy.</p>`
  }
};

function openHelpGuide(topicKey = "cycle") {
  const topic = HELP_TOPICS[topicKey] || HELP_TOPICS["cycle"];
  const html = `
    <div style="padding: 0.5rem 0;">
      <div class="explainer-box">${topic.content}</div>
      <div style="margin-top: 1.25rem;">
        <h4 style="font-size: 0.88rem; color: var(--text-secondary); margin-bottom: 0.5rem;">Explore Other Topics:</h4>
        <div class="chip-group">
          <button class="chip ${topicKey === 'cycle' ? 'active' : ''}" onclick="openHelpGuide('cycle')">📅 Salary Cycle</button>
          <button class="chip ${topicKey === 'completed' ? 'active' : ''}" onclick="openHelpGuide('completed')">✅ Completed Payments</button>
          <button class="chip ${topicKey === 'balance' ? 'active' : ''}" onclick="openHelpGuide('balance')">💰 Spendable Balance</button>
          <button class="chip ${topicKey === 'forecast' ? 'active' : ''}" onclick="openHelpGuide('forecast')">📐 Forecast Math</button>
          <button class="chip ${topicKey === 'bnpl' ? 'active' : ''}" onclick="openHelpGuide('bnpl')">🛍️ BNPL Tracking</button>
          <button class="chip ${topicKey === 'cms' ? 'active' : ''}" onclick="openHelpGuide('cms')">👑 Admin CMS</button>
        </div>
      </div>
    </div>
  `;
  openModal(topic.title, html, null);
}

// --- CRUD OPERATIONS ---

// 1. Members
function openMemberModal(member = null) {
  const isEdit = member !== null;
  const html = `
    <div class="form-group">
      <label>Member Name</label>
      <input type="text" id="m-name" class="form-control" value="${isEdit ? member.name : ''}" placeholder="e.g. Sathsara, Dhiyan">
    </div>
    <div class="form-group">
      <label>Role</label>
      <select id="m-role" class="form-control">
        <option value="husband" ${isEdit && member.role === 'husband' ? 'selected' : ''}>Husband</option>
        <option value="wife" ${isEdit && member.role === 'wife' ? 'selected' : ''}>Wife</option>
        <option value="partner" ${isEdit && member.role === 'partner' ? 'selected' : ''}>Partner</option>
        <option value="member" ${isEdit && member.role === 'member' ? 'selected' : ''}>Family Member</option>
        <option value="admin" ${isEdit && member.role === 'admin' ? 'selected' : ''}>Administrator</option>
      </select>
    </div>
    <div class="form-group">
      <label>Regular Monthly Base Salary (${state.household.currency})</label>
      <input type="number" id="m-salary" class="form-control" value="${isEdit ? member.salary : '150000'}">
    </div>
    <div class="form-group">
      <label>Avatar Color</label>
      <input type="color" id="m-color" class="form-control" value="${isEdit ? (member.color || '#10B981') : '#10B981'}" style="height: 40px; padding: 2px;">
    </div>
  `;
  openModal(isEdit ? "Edit Household Member" : "Add New Member", html, () => {
    const name = document.getElementById("m-name").value.trim();
    const role = document.getElementById("m-role").value.trim();
    const salary = parseFloat(document.getElementById("m-salary").value) || 0;
    const color = document.getElementById("m-color").value || "#10B981";

    if (!name) return showToast("Please enter a member name", "danger");

    if (isEdit) {
      member.name = name; member.role = role; member.salary = salary; member.color = color;
      showToast(`Updated member: ${name}`, "success");
    } else {
      state.members.push({ id: "m_" + Date.now(), name, role, salary, color });
      showToast(`Added member: ${name}`, "success");
    }
    closeModal();
    persistState();
    renderApp();
  });
}

function deleteMember(id) {
  const member = (state.members || []).find(m => m.id === id);
  const memberName = member ? member.name : "this member";

  customConfirm(`Delete member <strong>${memberName}</strong>? Incomes and assignments associated with this member will be detached cleanly.`, () => {
    state.members = (state.members || []).filter(m => m.id !== id);
    persistState();
    renderApp();
    showToast(`Deleted member: ${memberName}`, "success");
  });
}

// 1b. Income Management (Cycle Incomes)
function openIncomeModal(income = null) {
  const isEdit = income !== null;
  const memberOptions = (state.members || []).map(m =>
    `<option value="${m.id}" ${isEdit && income.memberId === m.id ? 'selected' : ''}>${m.name} (${m.role})</option>`
  ).join('');
  const today = new Date().toISOString().split("T")[0];
  const html = `
    <div class="form-group">
      <label>Member</label>
      <select id="inc-member" class="form-control">${memberOptions || '<option value="">No members yet</option>'}</select>
    </div>
    <div class="form-group">
      <label>Income Source / Label</label>
      <input type="text" id="inc-source" class="form-control" value="${isEdit ? income.source : ''}" placeholder="e.g. Monthly Salary, Bonus, Freelance">
    </div>
    <div class="form-group">
      <label>Amount (${state.household.currency})</label>
      <input type="number" id="inc-amount" class="form-control" value="${isEdit ? income.amount : ''}" placeholder="e.g. 250000">
    </div>
    <div class="form-group">
      <label>Date Received</label>
      <input type="date" id="inc-date" class="form-control" value="${isEdit ? income.date : today}">
    </div>
  `;
  openModal(isEdit ? "Edit Income Entry" : "Add Income Entry", html, () => {
    const memberId = document.getElementById("inc-member").value;
    const source = document.getElementById("inc-source").value.trim();
    const amount = parseFloat(document.getElementById("inc-amount").value) || 0;
    const date = document.getElementById("inc-date").value;
    if (!source || amount <= 0) return showToast("Please provide valid source and amount", "danger");
    if (isEdit) {
      income.memberId = memberId; income.source = source; income.amount = amount; income.date = date;
    } else {
      state.incomes = state.incomes || [];
      state.incomes.push({ id: "inc_" + Date.now(), memberId, source, amount, date });
    }
    closeModal();
    persistState();
    renderApp();
    showToast(`${isEdit ? 'Updated' : 'Added'} income: ${source} — ${fmt(amount)}`, "success");
  });
}

function deleteIncome(id) {
  customConfirm("Delete this income entry?", () => {
    state.incomes = (state.incomes || []).filter(i => i.id !== id);
    persistState();
    renderApp();
    showToast("Income entry deleted", "success");
  });
}

// 2. Fixed Bills

function openBillModal(bill = null) {
  const isEdit = bill !== null;
  const html = `
    <div class="form-group">
      <label>Bill Name / Purpose</label>
      <input type="text" id="b-name" class="form-control" value="${isEdit ? bill.name : ''}" placeholder="e.g. Apartment Rent, Personal Loan">
    </div>
    <div class="form-group">
      <label>Monthly Amount (${state.household.currency})</label>
      <input type="number" id="b-amount" class="form-control" value="${isEdit ? bill.amount : '20000'}">
    </div>
    <div class="form-group">
      <label>Category</label>
      <select id="b-cat" class="form-control">
        ${(state.fixedBillCategories || defaultState.fixedBillCategories).map(c => `<option value="${c.name}" ${isEdit && bill.category === c.name ? 'selected' : ''}>${c.name}</option>`).join('')}
      </select>
    </div>
    <div class="form-group">
      <label>Due Day of Month (e.g. 25th)</label>
      <input type="number" id="b-due" class="form-control" value="${isEdit ? bill.dueDay : '25'}">
    </div>
    <div class="form-group">
      <label>Destination Account / Bank</label>
      <input type="text" id="b-dest" class="form-control" value="${isEdit ? (bill.dest || '') : 'BOC Account'}">
    </div>
  `;
  openModal(isEdit ? "Edit Fixed Bill" : "Add Fixed Bill", html, () => {
    const name = document.getElementById("b-name").value.trim();
    const amount = parseFloat(document.getElementById("b-amount").value) || 0;
    const category = document.getElementById("b-cat").value;
    const dueDay = parseInt(document.getElementById("b-due").value) || 25;
    const dest = document.getElementById("b-dest").value.trim();

    if (!name || amount <= 0) return showToast("Please provide valid name and amount", "danger");

    if (isEdit) {
      bill.name = name; bill.amount = amount; bill.category = category; bill.dueDay = dueDay; bill.dest = dest;
    } else {
      state.fixedPayments.push({ id: "f_" + Date.now(), name, amount, category, dueDay, dest, isPaid: false, paidDate: null });
    }
    closeModal();
    persistState();
    renderApp();
    showToast(`${isEdit ? 'Updated' : 'Added'} bill: ${name}`, "success");
  });
}

function deleteBill(id) {
  customConfirm("Delete this fixed bill?", () => {
    state.fixedPayments = (state.fixedPayments || []).filter(f => f.id !== id);
    persistState();
    renderApp();
    showToast("Bill deleted", "success");
  });
}

// 3. BNPL
function openBnplModal(inst = null) {
  const isEdit = inst !== null;
  const html = `
    <div class="form-group">
      <label>Item Name / Purchase Description</label>
      <input type="text" id="i-name" class="form-control" value="${isEdit ? inst.item : ''}" placeholder="e.g. Water Filter, Perfume">
    </div>
    <div class="form-group">
      <label>Platform</label>
      <select id="i-plat" class="form-control">
        ${(state.bnplPlatforms || defaultState.bnplPlatforms).map(p => `<option value="${p.name}" ${isEdit && inst.platform === p.name ? 'selected' : ''}>${p.name}</option>`).join('')}
      </select>
    </div>
    <div class="form-group">
      <label>Purchased By Member</label>
      <select id="i-mem" class="form-control">
        ${(state.members || []).map(m => `<option value="${m.name}" ${isEdit && inst.member === m.name ? 'selected' : ''}>${m.name}</option>`).join('')}
      </select>
    </div>
    <div class="form-group">
      <label>Monthly Installment (${state.household.currency})</label>
      <input type="number" id="i-month" class="form-control" value="${isEdit ? inst.monthly : '4500'}">
    </div>
    <div class="form-group">
      <label>Remaining Balance (${state.household.currency})</label>
      <input type="number" id="i-rem" class="form-control" value="${isEdit ? inst.remaining : '9000'}">
    </div>
    <div class="form-group">
      <label>Total Price (${state.household.currency})</label>
      <input type="number" id="i-tot" class="form-control" value="${isEdit ? inst.total : '13500'}">
    </div>
  `;
  openModal(isEdit ? "Edit BNPL Plan" : "Add BNPL Plan", html, () => {
    const item = document.getElementById("i-name").value.trim();
    const platform = document.getElementById("i-plat").value;
    const member = document.getElementById("i-mem").value;
    const monthly = parseFloat(document.getElementById("i-month").value) || 0;
    const remaining = parseFloat(document.getElementById("i-rem").value) || 0;
    const total = parseFloat(document.getElementById("i-tot").value) || (monthly * 3);

    if (!item || monthly <= 0) return showToast("Please provide valid item and monthly amount", "danger");

    if (isEdit) {
      inst.item = item; inst.platform = platform; inst.member = member; inst.monthly = monthly; inst.remaining = remaining; inst.total = total;
    } else {
      state.installments.push({ id: "inst_" + Date.now(), item, platform, member, monthly, remaining, total, isPaid: false, paidDate: null });
    }
    closeModal();
    persistState();
    renderApp();
    showToast(`${isEdit ? 'Updated' : 'Added'} BNPL: ${item}`, "success");
  });
}

function deleteBnpl(id) {
  customConfirm("Delete this installment plan?", () => {
    state.installments = (state.installments || []).filter(i => i.id !== id);
    persistState();
    renderApp();
    showToast("BNPL plan deleted", "success");
  });
}

// 4. Subscriptions
function openSubModal(sub = null) {
  const isEdit = sub !== null;
  const html = `
    <div class="form-group">
      <label>Subscription Name</label>
      <input type="text" id="s-name" class="form-control" value="${isEdit ? sub.name : ''}" placeholder="e.g. Netflix, Dialog Router">
    </div>
    <div class="form-group">
      <label>Monthly Cost (${state.household.currency})</label>
      <input type="number" id="s-amt" class="form-control" value="${isEdit ? sub.amountLkr : '1500'}">
    </div>
    <div class="form-group">
      <label>Billing Day of Month</label>
      <input type="number" id="s-day" class="form-control" value="${isEdit ? sub.billingDay : '24'}">
    </div>
  `;
  openModal(isEdit ? "Edit Subscription" : "Add Subscription", html, () => {
    const name = document.getElementById("s-name").value.trim();
    const amountLkr = parseFloat(document.getElementById("s-amt").value) || 0;
    const billingDay = parseInt(document.getElementById("s-day").value) || 24;

    if (!name || amountLkr <= 0) return showToast("Please enter valid subscription details", "danger");

    if (isEdit) {
      sub.name = name; sub.amountLkr = amountLkr; sub.billingDay = billingDay;
    } else {
      state.subscriptions.push({ id: "s_" + Date.now(), name, amountLkr, billingDay, isPaid: false, paidDate: null });
    }
    closeModal();
    persistState();
    renderApp();
    showToast(`${isEdit ? 'Updated' : 'Added'} subscription: ${name}`, "success");
  });
}

function deleteSub(id) {
  customConfirm("Delete this subscription?", () => {
    state.subscriptions = (state.subscriptions || []).filter(s => s.id !== id);
    persistState();
    renderApp();
    showToast("Subscription deleted", "success");
  });
}

// 5. Credit Cards
function openCardModal(card = null) {
  const isEdit = card !== null;
  const html = `
    <div class="form-group">
      <label>Bank Name</label>
      <input type="text" id="c-bank" class="form-control" value="${isEdit ? card.bank : ''}" placeholder="e.g. Commercial Bank, Sampath">
    </div>
    <div class="form-group">
      <label>Card Name / Level</label>
      <input type="text" id="c-name" class="form-control" value="${isEdit ? card.name : ''}" placeholder="e.g. Platinum Visa, Signature">
    </div>
    <div class="form-group">
      <label>Statement Due Amount (${state.household.currency})</label>
      <input type="number" id="c-due" class="form-control" value="${isEdit ? card.due : '0'}">
    </div>
  `;
  openModal(isEdit ? "Edit Credit Card" : "Add Credit Card", html, () => {
    const bank = document.getElementById("c-bank").value.trim();
    const name = document.getElementById("c-name").value.trim();
    const due = parseFloat(document.getElementById("c-due").value) || 0;

    if (!bank || !name) return showToast("Please provide bank and card name", "danger");

    if (isEdit) {
      card.bank = bank; card.name = name; card.due = due;
    } else {
      state.creditCards.push({ id: "cc_" + Date.now(), bank, name, due, isPaid: false, paidDate: null });
    }
    closeModal();
    persistState();
    renderApp();
    showToast(`${isEdit ? 'Updated' : 'Added'} card: ${bank} ${name}`, "success");
  });
}

function deleteCard(id) {
  customConfirm("Delete this credit card?", () => {
    state.creditCards = (state.creditCards || []).filter(c => c.id !== id);
    persistState();
    renderApp();
    showToast("Credit card deleted", "success");
  });
}

// 6. Wishlist
function openWishlistModal(item = null) {
  const isEdit = item !== null;
  const html = `
    <div class="form-group">
      <label>Item Name</label>
      <input type="text" id="w-name" class="form-control" value="${isEdit ? item.item : ''}" placeholder="e.g. Air Fryer, Litro Gas Refill">
    </div>
    <div class="form-group">
      <label>Category
        <button type="button" class="btn-help-pill" style="margin-left: 0.5rem; font-size: 0.7rem;" onclick="openWishlistCategoryManager()">➕ Manage Categories</button>
      </label>
      <select id="w-cat" class="form-control">
        ${(state.wishlistCategories || defaultState.wishlistCategories).sort((a,b) => (a.sortOrder||0) - (b.sortOrder||0)).map(c => `<option value="${c.name}" ${isEdit && item.category === c.name ? 'selected' : ''}>${c.name}</option>`).join('')}
      </select>
    </div>
    <div class="form-group">
      <label>Estimated Cost (${state.household.currency})</label>
      <input type="number" id="w-cost" class="form-control" value="${isEdit ? item.cost : '2500'}">
    </div>
    <div class="form-group">
      <label>Priority</label>
      <select id="w-pri" class="form-control">
        <option value="high" ${isEdit && item.priority === 'high' ? 'selected' : ''}>High (Must Buy This Month)</option>
        <option value="medium" ${isEdit && item.priority === 'medium' ? 'selected' : ''}>Medium (If Surplus Exists)</option>
        <option value="low" ${isEdit && item.priority === 'low' ? 'selected' : ''}>Low (Future Wishlist)</option>
      </select>
    </div>
    <div class="form-group">
      <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
        <input type="checkbox" id="w-plan" ${isEdit && item.isPlanned ? 'checked' : ''} style="width: 18px; height: 18px;">
        <span>Plan for Current Cycle (Deduct from Spendable Balance)</span>
      </label>
    </div>
  `;
  openModal(isEdit ? "Edit Needs Item" : "Add Needs Item", html, () => {
    const itemName = document.getElementById("w-name").value.trim();
    const category = document.getElementById("w-cat").value;
    const cost = parseFloat(document.getElementById("w-cost").value) || 0;
    const priority = document.getElementById("w-pri").value;
    const isPlanned = document.getElementById("w-plan").checked;

    if (!itemName || cost <= 0) return showToast("Please enter valid item and cost", "danger");

    if (isEdit) {
      item.item = itemName; item.category = category; item.cost = cost; item.priority = priority; item.isPlanned = isPlanned;
    } else {
      state.wishlist.push({ id: "w_" + Date.now(), item: itemName, category, cost, priority, isPlanned, isPaid: false });
    }
    closeModal();
    persistState();
    renderApp();
    showToast(`${isEdit ? 'Updated' : 'Added'} wishlist item: ${itemName}`, "success");
  });
}

function deleteWishlist(id) {
  customConfirm("Delete this wishlist item?", () => {
    state.wishlist = (state.wishlist || []).filter(w => w.id !== id);
    persistState();
    renderApp();
    showToast("Wishlist item deleted", "success");
  });
}

// 7. Daily Spends — with member tracking
function openSpendModal() {
  const categoryOptions = (state.categories || defaultState.categories).map(c => `<option value="${c.name}">${c.name}</option>`).join('');
  const paymentOptions = (state.paymentMethods || defaultState.paymentMethods).map(p => `<option value="${p.name}">${p.name}</option>`).join('');
  const memberOptions = (state.members || []).length
    ? `<div class="form-group">
        <label>Who is spending this?</label>
        <select id="qs-member" class="form-control">
          <option value="">-- Household (shared) --</option>
          ${(state.members || []).map(m => `<option value="${m.id}">${m.name}</option>`).join('')}
        </select>
       </div>`
    : '';

  const html = `
    <div class="form-group">
      <label>Amount (${state.household.currency})</label>
      <input type="number" id="qs-amt" class="form-control form-control-lg" placeholder="0.00" autofocus>
    </div>
    <div class="form-group">
      <label>Description / Item</label>
      <input type="text" id="qs-title" class="form-control" placeholder="e.g. Food City Groceries, PickMe Tuk, Gym Water">
    </div>
    <div class="form-group">
      <label>Payment Method</label>
      <select id="qs-method" class="form-control">${paymentOptions}</select>
    </div>
    <div class="form-group">
      <label>Category</label>
      <select id="qs-cat" class="form-control">${categoryOptions}</select>
    </div>
    ${memberOptions}
  `;
  openModal("Quick Log Daily Expense", html, () => {
    const amount = parseFloat(document.getElementById("qs-amt").value) || 0;
    const title = document.getElementById("qs-title").value.trim();
    const method = document.getElementById("qs-method").value;
    const cat = document.getElementById("qs-cat").value;
    const memberId = document.getElementById("qs-member")?.value || "";
    const member = (state.members || []).find(m => m.id === memberId);

    if (amount <= 0 || !title) return showToast("Please enter amount and description", "danger");

    state.dailySpends.unshift({
      id: "d_" + Date.now(),
      date: new Date().toISOString().split("T")[0],
      amount,
      title,
      method,
      cat,
      memberId: memberId || null,
      memberName: member ? member.name : null,
      isPaid: true
    });
    closeModal();
    persistState();
    renderApp();
    checkDailySpendAlert();
    showToast(`Logged expense: ${fmt(amount)} for ${title}${member ? ' (' + member.name + ')' : ''}`, "success");
  });
}

function deleteSpend(id) {
  customConfirm("Delete this expense log?", () => {
    state.dailySpends = (state.dailySpends || []).filter(s => s.id !== id);
    persistState();
    renderApp();
    showToast("Expense log deleted", "success");
  });
}

// 8. Categories
function openCategoryModal(cat = null) {
  const isEdit = cat !== null;
  const html = `
    <div class="form-group">
      <label>Category Name</label>
      <input type="text" id="cat-name" class="form-control" value="${isEdit ? cat.name : ''}" placeholder="e.g. Groceries, Dining">
    </div>
    <div class="form-group">
      <label>Monthly Target Budget (${state.household.currency})</label>
      <input type="number" id="cat-budget" class="form-control" value="${isEdit ? (cat.monthlyBudget || 20000) : '20000'}">
    </div>
    <div class="form-group">
      <label>Category Color</label>
      <input type="color" id="cat-color" class="form-control" value="${isEdit ? (cat.color || '#10B981') : '#10B981'}" style="height: 40px; padding: 2px;">
    </div>
  `;
  openModal(isEdit ? "Edit Category" : "Add New Category", html, () => {
    const name = document.getElementById("cat-name").value.trim();
    const monthlyBudget = parseFloat(document.getElementById("cat-budget").value) || 0;
    const color = document.getElementById("cat-color").value || "#10B981";

    if (!name) return showToast("Please enter a category name", "danger");

    if (isEdit) {
      cat.name = name; cat.monthlyBudget = monthlyBudget; cat.color = color;
    } else {
      state.categories.push({ id: "cat_" + Date.now(), name, monthlyBudget, color });
    }
    closeModal();
    persistState();
    renderApp();
    showToast(`${isEdit ? 'Updated' : 'Added'} category: ${name}`, "success");
  });
}

function deleteCategory(id) {
  customConfirm("Delete this category?", () => {
    state.categories = (state.categories || []).filter(c => c.id !== id);
    persistState();
    renderApp();
    showToast("Category removed", "success");
  });
}

// Tab Switching
function switchTab(tabId) {
  document.querySelectorAll(".nav-item").forEach(btn => {
    btn.classList.toggle("active", btn.dataset.tab === tabId);
  });
  document.querySelectorAll(".tab-pane").forEach(pane => {
    pane.classList.toggle("active", pane.id === `tab-${tabId}`);
  });
  if (tabId === "cms-labels") {
    renderLabelsCmsScreen();
  }
  if (tabId === "cms-ai") {
    renderAiStudioFields();
  }
  if (tabId === "analytics") {
    setTimeout(() => renderAnalyticsDashboard(), 50);
  }
  if (tabId === "calendar") {
    renderCalendarView();
  }
  if (tabId === "cms-supabase") {
    testSupabaseConnection();
  }
  if (tabId === "cms-categories") {
    // Render platform and wishlist category preview chips in Admin
    const platPreview = document.getElementById("bnpl-platform-preview");
    if (platPreview) {
      platPreview.innerHTML = (state.bnplPlatforms || []).map(p =>
        `<span style="background: ${p.color}22; color: ${p.color}; border: 1px solid ${p.color}44; border-radius: 999px; padding: 0.2rem 0.75rem; font-size: 0.8rem; font-weight: 600;">${p.name}</span>`
      ).join('');
    }
    const wcatPreview = document.getElementById("wishlist-cat-preview");
    if (wcatPreview) {
      wcatPreview.innerHTML = (state.wishlistCategories || []).sort((a,b) => (a.sortOrder||0)-(b.sortOrder||0)).map(c =>
        `<span style="background: rgba(99,102,241,0.15); color: #818cf8; border: 1px solid rgba(99,102,241,0.3); border-radius: 999px; padding: 0.2rem 0.75rem; font-size: 0.8rem;">${c.name}</span>`
      ).join('');
    }
  }
}

// Custom CSS & Settings
function selectThemePreset(themeClass) {
  document.body.className = themeClass;
  state.household.themePreset = themeClass;
  persistState();
  document.querySelectorAll(".theme-card").forEach(c => {
    c.classList.toggle("active", c.dataset.theme === themeClass);
  });
  showToast(`Switched theme to ${themeClass.replace('theme-', '')}`, "info");
}

function saveThemeAndBranding() {
  const name = document.getElementById("cms-app-name-input")?.value.trim();
  const tagline = document.getElementById("cms-tagline-input")?.value.trim();
  const logo = document.getElementById("cms-app-logo-input")?.value.trim();
  const currency = document.getElementById("cms-currency-input")?.value.trim();
  const customCss = document.getElementById("cms-custom-css")?.value;

  if (name) state.household.name = name;
  if (tagline) state.household.tagline = tagline;
  if (logo) state.household.logo = logo;
  if (currency) state.household.currency = currency;
  if (customCss !== undefined) state.household.customCss = customCss;

  persistState();
  applyCustomCss();
  renderApp();
  showToast("Appearance & Branding saved live with zero redeploy!", "success");
}

function applyCustomCss() {
  let styleTag = document.getElementById("user-custom-css-tag");
  if (!styleTag) {
    styleTag = document.createElement("style");
    styleTag.id = "user-custom-css-tag";
    document.head.appendChild(styleTag);
  }
  styleTag.textContent = state.household?.customCss || "";
}

function toggleComponent(key, isChecked) {
  if (!state.uiComponents) state.uiComponents = { ...defaultState.uiComponents };
  state.uiComponents[key] = isChecked;
  persistState();
  renderApp();
  showToast(`Updated frontend layout for ${key}`, "info");
}

function saveForecastSettings() {
  const reserve = parseFloat(document.getElementById("fc-reserve-input")?.value) || 5.0;
  const days = parseInt(document.getElementById("fc-days-input")?.value) || 30;
  state.forecastSettings.reservePercentage = reserve;
  state.forecastSettings.survivalBufferDays = days;
  persistState();
  renderApp();
  updateMathSandbox();
  showToast("Forecast engine parameters saved!", "success");
}

function updateMathSandbox() {
  const salaryMod = parseFloat(document.getElementById("sb-salary-slider")?.value) || 100;
  const shockAmt = parseFloat(document.getElementById("sb-shock-input")?.value) || 0;
  const reservePct = parseFloat(document.getElementById("fc-reserve-input")?.value) || (state.forecastSettings?.reservePercentage || 5.0);

  const baseIncome = (state.incomes || []).reduce((acc, i) => acc + (Number(i.amount) || 0), 0);
  const simulatedIncome = (baseIncome * (salaryMod / 100));

  const totalFixed = (state.fixedPayments || []).reduce((acc, f) => acc + (Number(f.amount) || 0), 0);
  const totalSubs = (state.subscriptions || []).reduce((acc, s) => acc + (Number(s.amountLkr) || 0), 0);
  const continuingBnpl = (state.installments || []).filter(i => (i.remaining || 0) > (i.monthly || 0)).reduce((acc, i) => acc + (Number(i.monthly) || 0), 0);
  const totalCommitted = totalFixed + totalSubs + 10000 + continuingBnpl + shockAmt;

  const netDiff = simulatedIncome - totalCommitted;
  const hasShortfall = netDiff < 0;
  const safetyReserveAmt = simulatedIncome * (reservePct / 100);
  const requiredBuffer = hasShortfall ? Math.abs(netDiff) + safetyReserveAmt : safetyReserveAmt;

  const resEl = document.getElementById("sb-output-container");
  if (resEl) {
    resEl.innerHTML = `
      <div style="flex: 1; min-width: 250px;">
        <div style="font-size: 0.8rem; color: var(--text-secondary);">SIMULATED SALARY (${salaryMod}%)</div>
        <div style="font-size: 1.3rem; font-weight: 800; color: #FFF;">${fmt(simulatedIncome)}</div>
        <div style="font-size: 0.75rem; color: var(--text-muted);">Committed Bills: ${fmt(totalCommitted)}</div>
      </div>
      <div style="flex: 1; min-width: 250px;">
        <div style="font-size: 0.8rem; color: var(--text-secondary);">PROJECTED OUTCOME</div>
        <div style="font-size: 1.3rem; font-weight: 800; color: ${hasShortfall ? 'var(--danger)' : 'var(--success)'};">
          ${hasShortfall ? '⚠️ SHORTFALL: - ' + fmt(Math.abs(netDiff)) : '✅ SURPLUS: + ' + fmt(netDiff)}
        </div>
        <div style="font-size: 0.75rem; color: var(--text-muted);">Mandatory Safety Buffer: <strong>${fmt(requiredBuffer)}</strong></div>
      </div>
    `;
  }
}

function saveAiSettings() {
  const provider = document.getElementById("ai-provider-select")?.value || "gemini";
  const geminiKey = document.getElementById("ai-gemini-key")?.value.trim() || "";
  const openaiKey = document.getElementById("ai-openai-key")?.value.trim() || "";
  const model = document.getElementById("ai-model-select")?.value || "gemini-1.5-flash";
  const tone = document.getElementById("ai-tone-select")?.value || "balanced";

  state.aiSettings = { provider, geminiKey, openaiKey, model, tone };
  persistState();

  const activeKey = provider === "openai" ? openaiKey : geminiKey;
  if (activeKey) {
    showToast(`✅ AI settings saved! Key active: ${activeKey.slice(0, 8)}...${activeKey.slice(-4)} (synced to cloud)`, "success");
  } else {
    showToast("AI settings saved. No API key set — AI will use rule-based advice.", "info");
  }
}

// Populates AI Studio form fields with stored values when tab is opened
function renderAiStudioFields() {
  const s = state.aiSettings || {};
  const provEl = document.getElementById("ai-provider-select");
  const modelEl = document.getElementById("ai-model-select");
  const gemKeyEl = document.getElementById("ai-gemini-key");
  const oaiKeyEl = document.getElementById("ai-openai-key");
  const toneEl = document.getElementById("ai-tone-select");
  if (provEl) provEl.value = s.provider || "gemini";
  if (modelEl) modelEl.value = s.model || "gemini-1.5-flash";
  if (gemKeyEl && s.geminiKey) gemKeyEl.placeholder = `Key saved: ${s.geminiKey.slice(0,8)}...${s.geminiKey.slice(-4)} (enter new to replace)`;
  if (oaiKeyEl && s.openaiKey) oaiKeyEl.placeholder = `Key saved: ${s.openaiKey.slice(0,8)}...${s.openaiKey.slice(-4)} (enter new to replace)`;
  if (toneEl) toneEl.value = s.tone || "balanced";
}

async function testAiConnection() {
  const outputEl = document.getElementById("ai-test-output");
  if (outputEl) outputEl.innerHTML = "<em>Connecting to AI provider...</em>";

  const metrics = calculateMetrics();
  const activeKey = state.aiSettings?.provider === "openai" ? state.aiSettings?.openaiKey : state.aiSettings?.geminiKey;
  const prompt = `Household Brief: Income: ${fmt(metrics.totalIncome)}, Committed: ${fmt(metrics.totalCommitted)}, Balance: ${fmt(metrics.remainingBalance)}. Provide 2 sentences of advice.`;

  if (!activeKey) {
    if (outputEl) outputEl.innerHTML = `<span style="color: var(--warning);">⚠️ No key set. Local Rule Engine advice:</span><br><strong>Surplus active:</strong> You have ${fmt(metrics.remainingBalance)} remaining. All commitments funded.`;
    return;
  }

  try {
    const url = state.aiSettings?.provider === "openai"
      ? "https://api.openai.com/v1/chat/completions"
      : `https://generativelanguage.googleapis.com/v1beta/models/${state.aiSettings.model || 'gemini-1.5-flash'}:generateContent?key=${activeKey}`;

    let responseText = "";
    if (state.aiSettings.provider === "openai") {
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json", "Authorization": `Bearer ${activeKey}` },
        body: JSON.stringify({ model: state.aiSettings.model || "gpt-4o-mini", messages: [{ role: "user", content: prompt }] })
      });
      const data = await res.json();
      responseText = data.choices?.[0]?.message?.content || "Connected!";
    } else {
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
      });
      const data = await res.json();
      responseText = data.candidates?.[0]?.content?.parts?.[0]?.text || "Connected!";
    }
    if (outputEl) outputEl.innerHTML = `<span style="color: var(--success);">✅ Connection Success (${state.aiSettings.provider}):</span><br>${responseText}`;
  } catch (err) {
    if (outputEl) outputEl.innerHTML = `<span style="color: var(--danger);">❌ Connection Failed: ${err.message}</span>`;
  }
}

function exportDatabaseJson() {
  const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(state, null, 2));
  const a = document.createElement("a");
  a.href = dataStr;
  a.download = `homebudget_backup_${new Date().toISOString().split('T')[0]}.json`;
  document.body.appendChild(a);
  a.click();
  a.remove();
  showToast("Database exported as JSON", "success");
}

function importDatabaseJson(event) {
  const file = event.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = function(e) {
    try {
      const parsed = JSON.parse(e.target.result);
      if (parsed.household && parsed.members) {
        state = parsed;
        persistState();
        renderApp();
        showToast("Database restored successfully!", "success");
      } else {
        showToast("Invalid JSON backup", "danger");
      }
    } catch (err) {
      showToast("JSON parsing error", "danger");
    }
  };
  reader.readAsText(file);
}

function resetToSampleData() {
  customConfirm("⚠️ Clear all personal financial data? This removes all members, incomes, bills, BNPL, spends and cycle history. Lookup tables (platforms, categories) are kept. This cannot be undone.", () => {
    // Keep configuration/lookup tables, clear personal data only
    const keepConfig = {
      bnplPlatforms: state.bnplPlatforms,
      fixedBillCategories: state.fixedBillCategories,
      wishlistCategories: state.wishlistCategories,
      categories: state.categories,
      paymentMethods: state.paymentMethods,
      household: state.household,
      uiComponents: state.uiComponents,
      uiLabels: state.uiLabels,
      forecastSettings: state.forecastSettings,
      adminProfile: state.adminProfile,
      aiSettings: state.aiSettings // preserve AI key set by user
    };
    state = Object.assign(JSON.parse(JSON.stringify(defaultState)), keepConfig);
    persistState();
    renderApp();
    showToast("All personal data cleared. Add your household members to get started.", "info");
  });
}

// First-run check — true if no members have been added yet
function isFirstRun() {
  return !state.members || state.members.length === 0;
}

// First-run onboarding wizard — shown on fresh installations
function showFirstRunOnboarding() {
  // Calculate current cycle name from today's date
  const now = new Date();
  const cycleDay = state.household?.cycleStartDay || 25;
  let cycleStart = new Date(now.getFullYear(), now.getMonth(), cycleDay);
  if (now.getDate() < cycleDay) {
    cycleStart = new Date(now.getFullYear(), now.getMonth() - 1, cycleDay);
  }
  let cycleEnd = new Date(cycleStart.getFullYear(), cycleStart.getMonth() + 1, cycleDay);
  const daysLeft = Math.max(0, Math.ceil((cycleEnd - now) / (1000 * 60 * 60 * 24)));
  const cycleName = cycleStart.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) + ' – ' + cycleEnd.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });

  const html = `
    <div style="text-align: center; padding: 0.5rem 0 1rem;">
      <div style="font-size: 3rem; margin-bottom: 0.5rem;">🏠</div>
      <h2 style="font-size: 1.4rem; color: #F3F4F6; margin-bottom: 0.5rem;">Welcome to HomeBudget!</h2>
      <p style="color: var(--text-muted); font-size: 0.9rem;">Let's set up your household in 3 quick steps.</p>
    </div>

    <div class="explainer-box" style="margin-bottom: 1.25rem;">
      <strong>📅 Detected Cycle:</strong> ${cycleName} &nbsp;|&nbsp; <strong>${daysLeft} days remaining</strong>
    </div>

    <div class="form-group">
      <label>Step 1 — Your Name (Primary Member)</label>
      <input type="text" id="ob-name1" class="form-control" placeholder="e.g. Sathsara" autofocus>
    </div>
    <div class="form-group">
      <label>Monthly Salary (${state.household.currency})</label>
      <input type="number" id="ob-salary1" class="form-control" placeholder="e.g. 250000">
    </div>
    <hr style="border-color: rgba(255,255,255,0.08); margin: 1rem 0;">
    <div class="form-group">
      <label>Step 2 — Partner / Second Member Name <small style="color: var(--text-muted);">(optional)</small></label>
      <input type="text" id="ob-name2" class="form-control" placeholder="e.g. Dhiyan">
    </div>
    <div class="form-group">
      <label>Partner Monthly Salary (${state.household.currency}) <small style="color: var(--text-muted);">(optional)</small></label>
      <input type="number" id="ob-salary2" class="form-control" placeholder="e.g. 150000">
    </div>
    <hr style="border-color: rgba(255,255,255,0.08); margin: 1rem 0;">
    <div class="form-group">
      <label>Step 3 — Household Name <small style="color: var(--text-muted);">(appears in sidebar)</small></label>
      <input type="text" id="ob-hname" class="form-control" value="${state.household.name}" placeholder="e.g. HomeBudget">
    </div>
  `;

  openModal("🚀 First-Time Setup", html, () => {
    const name1 = document.getElementById("ob-name1").value.trim();
    const salary1 = parseFloat(document.getElementById("ob-salary1").value) || 0;
    const name2 = document.getElementById("ob-name2").value.trim();
    const salary2 = parseFloat(document.getElementById("ob-salary2").value) || 0;
    const hname = document.getElementById("ob-hname").value.trim();

    if (!name1 || salary1 <= 0) return showToast("Please enter at least your name and salary to continue.", "danger");

    // Add primary member
    state.members = [{ id: "m_" + Date.now(), name: name1, role: "primary", salary: salary1, color: "#10B981" }];
    // Add incomes for this cycle
    const today = new Date().toISOString().split("T")[0];
    state.incomes = [{ id: "inc_" + Date.now(), memberId: state.members[0].id, source: name1 + " Salary", amount: salary1, date: today }];

    // Optionally add partner
    if (name2 && salary2 > 0) {
      const m2id = "m_" + (Date.now() + 1);
      state.members.push({ id: m2id, name: name2, role: "partner", salary: salary2, color: "#EC4899" });
      state.incomes.push({ id: "inc_" + (Date.now() + 1), memberId: m2id, source: name2 + " Salary", amount: salary2, date: today });
    }

    // Update household name and active cycle
    if (hname) state.household.name = hname;
    state.activeCycle = { name: cycleName, daysRemaining: daysLeft };

    closeModal();
    persistState();
    renderApp();
    showToast(`✅ Welcome ${name1}! Your household is set up. Now add your fixed bills and BNPL plans from the top bar.`, "success");
  });
}

// --- MASTER RENDERER ---
function renderApp() {
  if (state.household?.themePreset) {
    document.body.className = state.household.themePreset;
  }
  applyCustomCss();

  // Dynamic UI Labels Injection into all matching [data-label-key] elements
  document.querySelectorAll("[data-label-key]").forEach(el => {
    const key = el.dataset.labelKey;
    if (key) {
      el.textContent = getLabel(key, el.textContent);
    }
  });

  // Branding
  document.querySelectorAll("#app-logo-icon, .app-logo-icon").forEach(el => el.textContent = state.household?.logo || "💰");
  document.querySelectorAll("#sidebar-app-name, .sidebar-app-name").forEach(el => el.textContent = state.household?.name || "HomeBudget");
  document.querySelectorAll("#sidebar-cycle-tag, .sidebar-cycle-tag").forEach(el => el.textContent = state.household?.tagline || "25th-to-25th Cycle");

  const metrics = calculateMetrics();

  // Displays
  const remainingEl = document.getElementById("remaining-balance-display");
  if (remainingEl) remainingEl.textContent = fmt(metrics.remainingBalance);

  const projectedEl = document.getElementById("projected-savings-display");
  if (projectedEl) projectedEl.textContent = fmt(metrics.projectedSavings);

  const totalIncEl = document.getElementById("total-income-display");
  if (totalIncEl) totalIncEl.textContent = fmt(metrics.totalIncome);

  const metricInc = document.getElementById("metric-income");
  if (metricInc) metricInc.textContent = fmt(metrics.totalIncome);

  const metricCom = document.getElementById("metric-committed");
  if (metricCom) metricCom.textContent = fmt(metrics.totalCommitted);

  const metricSp = document.getElementById("metric-spent");
  if (metricSp) metricSp.textContent = fmt(metrics.totalDailySpent);

  const metricWish = document.getElementById("metric-wishlist");
  if (metricWish) metricWish.textContent = fmt(metrics.totalPlannedWishlist);

  if (document.getElementById("bk-fixed")) document.getElementById("bk-fixed").textContent = fmt(metrics.totalFixed);
  if (document.getElementById("bk-installments")) document.getElementById("bk-installments").textContent = fmt(metrics.totalInstallments);
  if (document.getElementById("bk-cc")) document.getElementById("bk-cc").textContent = fmt(metrics.totalCreditCards);
  if (document.getElementById("bk-subs")) document.getElementById("bk-subs").textContent = fmt(metrics.totalSubscriptions);

  // Dynamic Component Visibility
  if (state.uiComponents) {
    const comp = state.uiComponents;
    const setVis = (id, show) => {
      const el = document.getElementById(id);
      if (el) el.style.display = show ? "" : "none";
    };
    setVis("frontend-balance-card", comp.showBalanceCard !== false);
    setVis("frontend-ai-card", comp.showAiAdvisorCard !== false);
    setVis("frontend-metrics-grid", comp.showMetricsGrid !== false);
    setVis("frontend-breakdown-card", comp.showBreakdownTable !== false);
    setVis("frontend-recent-spends-card", comp.showRecentSpends !== false);
  }

  // Completed badge count
  const completedCount = 
    (state.fixedPayments || []).filter(f => f.isPaid).length +
    (state.installments || []).filter(i => i.isPaid).length +
    (state.subscriptions || []).filter(s => s.isPaid).length +
    (state.creditCards || []).filter(c => c.isPaid).length +
    (state.wishlist || []).filter(w => w.isPaid).length;

  document.querySelectorAll(".badge-completed-count").forEach(el => el.textContent = completedCount);

  // Admin stats
  if (document.getElementById("admin-stat-members")) {
    document.getElementById("admin-stat-members").textContent = (state.members || []).length;
    document.getElementById("admin-stat-income").textContent = fmt(metrics.totalIncome);
    document.getElementById("admin-stat-committed").textContent = fmt(metrics.totalCommitted);
    document.getElementById("admin-stat-reserve").textContent = `${metrics.reservePct}% (${fmt(metrics.safetyReserveAmount)})`;
  }

  // Populate Admin Branding Inputs
  const appNameInp = document.getElementById("cms-app-name-input");
  if (appNameInp && state.household?.name) appNameInp.value = state.household.name;
  const taglineInp = document.getElementById("cms-tagline-input");
  if (taglineInp && state.household?.tagline) taglineInp.value = state.household.tagline;
  const logoInp = document.getElementById("cms-app-logo-input");
  if (logoInp && state.household?.logo) logoInp.value = state.household.logo;
  const currInp = document.getElementById("cms-currency-input");
  if (currInp && state.household?.currency) currInp.value = state.household.currency;
  const cssInp = document.getElementById("cms-custom-css");
  if (cssInp && state.household?.customCss !== undefined) cssInp.value = state.household.customCss;

  // Render CMS Labels Editor if on admin page
  if (document.getElementById("cms-labels-container")) {
    renderLabelsCmsScreen();
  }

  // Render Tables & Lists
  renderAllTables(metrics);

  // Update Math Sandbox
  updateMathSandbox();
}

function renderAllTables(metrics) {
  // 1. Members Table
  const membersBody = document.getElementById("cms-members-table-body");
  if (membersBody) {
    membersBody.innerHTML = (state.members || []).map(m => `
      <tr>
        <td>
          <div style="display: flex; align-items: center; gap: 0.5rem;">
            <span class="avatar" style="background: ${m.color || 'var(--primary)'}; width: 26px; height: 26px; font-size: 0.75rem;">${(m.name || 'M')[0]}</span>
            <strong>${m.name}</strong>
          </div>
        </td>
        <td><span class="badge badge-admin">${m.role}</span></td>
        <td><strong>${fmt(m.salary)}</strong></td>
        <td>
          <div class="action-btns">
            <button class="btn-table-edit" onclick="openMemberModal(state.members.find(x => x.id === '${m.id}'))">✏️ Edit</button>
            <button class="btn-table-delete" onclick="deleteMember('${m.id}')">🗑️ Delete</button>
          </div>
        </td>
      </tr>
    `).join("");
  }

  // 1b. Income Table (Cycle Incomes)
  const incomesBody = document.getElementById("cms-incomes-table-body");
  if (incomesBody) {
    incomesBody.innerHTML = (state.incomes || []).length ? (state.incomes || []).map(inc => {
      const member = (state.members || []).find(m => m.id === inc.memberId);
      return `
        <tr>
          <td><strong>${inc.source}</strong></td>
          <td>${member ? `<span class="avatar" style="background:${member.color||'var(--primary)'}; width:22px; height:22px; font-size:0.7rem; display:inline-flex;">${member.name[0]}</span> ${member.name}` : '<span style="color:var(--text-muted)">Unassigned</span>'}</td>
          <td><strong style="color: var(--primary-light);">${fmt(inc.amount)}</strong></td>
          <td style="color: var(--text-muted);">${inc.date}</td>
          <td>
            <div class="action-btns">
              <button class="btn-table-edit" onclick="openIncomeModal(state.incomes.find(x => x.id === '${inc.id}'))">✏️ Edit</button>
              <button class="btn-table-delete" onclick="deleteIncome('${inc.id}')">🗑️ Delete</button>
            </div>
          </td>
        </tr>
      `;
    }).join("") : `<tr><td colspan="5" style="text-align:center; color:var(--text-muted); padding:1rem;">No income entries yet. Click "➕ Add Income" to log this cycle's salaries.</td></tr>`;
  }

  // 2. Categories Table

  const catBody = document.getElementById("cms-categories-table-body");
  if (catBody) {
    catBody.innerHTML = (state.categories || []).map(c => `
      <tr>
        <td>
          <span class="category-tag">
            <span class="category-dot" style="background: ${c.color};"></span>
            <strong>${c.name}</strong>
          </span>
        </td>
        <td><strong>${fmt(c.monthlyBudget)}</strong> / month</td>
        <td>
          <div class="action-btns">
            <button class="btn-table-edit" onclick="openCategoryModal(state.categories.find(x => x.id === '${c.id}'))">✏️ Edit</button>
            <button class="btn-table-delete" onclick="deleteCategory('${c.id}')">🗑️ Delete</button>
          </div>
        </td>
      </tr>
    `).join("");
  }

  // 3. Fixed Bills Tables (Active vs Completed)
  const renderFixedRow = (b) => `
    <tr class="${b.isPaid ? 'paid-row' : ''}">
      <td>
        <button class="btn-pay-tick ${b.isPaid ? 'is-paid' : ''}" onclick="togglePaymentStatus('fixed', '${b.id}')">
          ${b.isPaid ? '✅ Paid' : '⭕ Mark Paid'}
        </button>
      </td>
      <td><strong>${b.name}</strong></td>
      <td><span class="badge">${b.category}</span></td>
      <td>${b.dueDay}th of month</td>
      <td><strong style="color: ${b.isPaid ? 'var(--primary-light)' : '#FFF'};">${fmt(b.amount)}</strong></td>
      <td>
        <div class="action-btns">
          <button class="btn-table-edit" onclick="openBillModal(state.fixedPayments.find(x => x.id === '${b.id}'))">✏️ Edit</button>
          <button class="btn-table-delete" onclick="deleteBill('${b.id}')">🗑️ Delete</button>
        </div>
      </td>
    </tr>
  `;

  const billsActiveBody = document.getElementById("bills-active-table-body");
  if (billsActiveBody) {
    const active = (state.fixedPayments || []).filter(b => !b.isPaid);
    billsActiveBody.innerHTML = active.length ? active.map(renderFixedRow).join("") : `<tr><td colspan="6" style="text-align: center; color: var(--primary-light); padding: 1.5rem;">🎉 All fixed bills for this cycle are completed!</td></tr>`;
  }
  const billsCompletedBody = document.getElementById("bills-completed-table-body");
  if (billsCompletedBody) {
    const completed = (state.fixedPayments || []).filter(b => b.isPaid);
    billsCompletedBody.innerHTML = completed.length ? completed.map(renderFixedRow).join("") : `<tr><td colspan="6" style="text-align: center; color: var(--text-muted); padding: 1rem;">No fixed bills marked as paid yet.</td></tr>`;
  }
  const cmsBillsBody = document.getElementById("cms-bills-table-body");
  if (cmsBillsBody) {
    cmsBillsBody.innerHTML = (state.fixedPayments || []).map(renderFixedRow).join("");
  }

  // 4. BNPL Tables (Active vs Completed)
  const renderBnplRow = (i) => `
    <tr class="${i.isPaid ? 'paid-row' : ''}">
      <td>
        <button class="btn-pay-tick ${i.isPaid ? 'is-paid' : ''}" onclick="togglePaymentStatus('bnpl', '${i.id}')">
          ${i.isPaid ? '✅ Paid' : '⭕ Mark Paid'}
        </button>
      </td>
      <td><strong>${i.item}</strong></td>
      <td><span class="badge badge-admin">${i.platform}</span></td>
      <td>${i.member || 'Dhiyan'}</td>
      <td><strong>${fmt(i.monthly)}</strong></td>
      <td>${fmt(i.remaining)} / ${fmt(i.total)}</td>
      <td>
        <div class="action-btns">
          <button class="btn-table-edit" onclick="openBnplModal(state.installments.find(x => x.id === '${i.id}'))">✏️ Edit</button>
          <button class="btn-table-delete" onclick="deleteBnpl('${i.id}')">🗑️ Delete</button>
        </div>
      </td>
    </tr>
  `;

  const bnplActiveBody = document.getElementById("bnpl-active-table-body");
  if (bnplActiveBody) {
    const active = (state.installments || []).filter(i => !i.isPaid);
    bnplActiveBody.innerHTML = active.length ? active.map(renderBnplRow).join("") : `<tr><td colspan="7" style="text-align: center; color: var(--primary-light); padding: 1.5rem;">🎉 All BNPL installments for this cycle are completed!</td></tr>`;
  }
  const bnplCompletedBody = document.getElementById("bnpl-completed-table-body");
  if (bnplCompletedBody) {
    const completed = (state.installments || []).filter(i => i.isPaid);
    bnplCompletedBody.innerHTML = completed.length ? completed.map(renderBnplRow).join("") : `<tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 1rem;">No BNPL plans settled yet this cycle.</td></tr>`;
  }
  const cmsBnplBody = document.getElementById("cms-bnpl-table-body");
  if (cmsBnplBody) {
    cmsBnplBody.innerHTML = (state.installments || []).map(renderBnplRow).join("");
  }

  // 5. Subscriptions Tables (Active vs Completed)
  const renderSubRow = (s) => `
    <tr class="${s.isPaid ? 'paid-row' : ''}">
      <td>
        <button class="btn-pay-tick ${s.isPaid ? 'is-paid' : ''}" onclick="togglePaymentStatus('sub', '${s.id}')">
          ${s.isPaid ? '✅ Paid' : '⭕ Mark Paid'}
        </button>
      </td>
      <td><strong>${s.name}</strong></td>
      <td>${s.billingDay}th of month</td>
      <td><strong>${fmt(s.amountLkr)}</strong></td>
      <td>
        <div class="action-btns">
          <button class="btn-table-edit" onclick="openSubModal(state.subscriptions.find(x => x.id === '${s.id}'))">✏️ Edit</button>
          <button class="btn-table-delete" onclick="deleteSub('${s.id}')">🗑️ Delete</button>
        </div>
      </td>
    </tr>
  `;

  const subsActiveBody = document.getElementById("subs-active-table-body");
  if (subsActiveBody) {
    const active = (state.subscriptions || []).filter(s => !s.isPaid);
    subsActiveBody.innerHTML = active.length ? active.map(renderSubRow).join("") : `<tr><td colspan="5" style="text-align: center; color: var(--primary-light); padding: 1.5rem;">🎉 All subscriptions settled for this cycle!</td></tr>`;
  }
  const subsCompletedBody = document.getElementById("subs-completed-table-body");
  if (subsCompletedBody) {
    const completed = (state.subscriptions || []).filter(s => s.isPaid);
    subsCompletedBody.innerHTML = completed.length ? completed.map(renderSubRow).join("") : `<tr><td colspan="5" style="text-align: center; color: var(--text-muted); padding: 1rem;">No subscriptions marked paid yet.</td></tr>`;
  }

  // 6. Credit Cards
  const renderCardRow = (c) => `
    <tr class="${c.isPaid ? 'paid-row' : ''}">
      <td>
        <button class="btn-pay-tick ${c.isPaid ? 'is-paid' : ''}" onclick="togglePaymentStatus('card', '${c.id}')">
          ${c.isPaid ? '✅ Paid' : '⭕ Mark Paid'}
        </button>
      </td>
      <td><strong>${c.bank}</strong> (${c.name})</td>
      <td><strong>${fmt(c.due)}</strong></td>
      <td>
        <div class="action-btns">
          <button class="btn-table-edit" onclick="openCardModal(state.creditCards.find(x => x.id === '${c.id}'))">✏️ Edit</button>
          <button class="btn-table-delete" onclick="deleteCard('${c.id}')">🗑️ Delete</button>
        </div>
      </td>
    </tr>
  `;
  const cardsBody = document.getElementById("cards-table-body");
  if (cardsBody) {
    cardsBody.innerHTML = (state.creditCards || []).map(renderCardRow).join("");
  }

  // 7. Wishlist / Needs Planner Table
  const renderWishlistRow = (w) => `
    <tr class="${w.isPaid ? 'paid-row' : ''}">
      <td>
        <button class="btn-pay-tick ${w.isPaid ? 'is-paid' : ''}" onclick="togglePaymentStatus('wishlist', '${w.id}')">
          ${w.isPaid ? '✅ Bought' : '⭕ Mark Bought'}
        </button>
      </td>
      <td><strong>${w.item}</strong></td>
      <td><span class="badge">${w.category}</span></td>
      <td>
        <span class="badge ${w.priority === 'high' ? 'badge-danger' : w.priority === 'medium' ? 'badge-admin' : ''}">
          ${w.priority.toUpperCase()}
        </span>
      </td>
      <td><strong>${fmt(w.cost)}</strong></td>
      <td>
        <span class="badge ${w.isPlanned ? 'badge-success' : ''}">
          ${w.isPlanned ? 'Planned This Cycle' : 'Deferred'}
        </span>
      </td>
      <td>
        <div class="action-btns">
          <button class="btn-table-edit" onclick="openWishlistModal(state.wishlist.find(x => x.id === '${w.id}'))">✏️ Edit</button>
          <button class="btn-table-delete" onclick="deleteWishlist('${w.id}')">🗑️ Delete</button>
        </div>
      </td>
    </tr>
  `;
  const wishlistActiveBody = document.getElementById("wishlist-active-table-body");
  if (wishlistActiveBody) {
    const active = (state.wishlist || []).filter(w => !w.isPaid);
    wishlistActiveBody.innerHTML = active.length ? active.map(renderWishlistRow).join("") : `<tr><td colspan="7" style="text-align: center; color: var(--primary-light); padding: 1rem;">No pending needs items.</td></tr>`;
  }
  const wishlistCompletedBody = document.getElementById("wishlist-completed-table-body");
  if (wishlistCompletedBody) {
    const completed = (state.wishlist || []).filter(w => w.isPaid);
    wishlistCompletedBody.innerHTML = completed.length ? completed.map(renderWishlistRow).join("") : `<tr><td colspan="7" style="text-align: center; color: var(--text-muted); padding: 1rem;">No needs items purchased yet.</td></tr>`;
  }

  // 8. Spends
  const recentSpends = document.getElementById("dashboard-recent-spends");
  if (recentSpends) {
    recentSpends.innerHTML = (state.dailySpends || []).slice(0, 5).map(s => `
      <div class="spend-row">
        <div class="spend-info">
          <strong>${s.title}</strong>
          <small>${s.date} • ${s.cat} • ${s.method}</small>
        </div>
        <div style="display: flex; align-items: center; gap: 0.75rem;">
          <strong class="spend-amount" style="color: var(--danger);">- ${fmt(s.amount)}</strong>
          <button class="btn-table-delete" onclick="deleteSpend('${s.id}')" title="Delete Spend">🗑️</button>
        </div>
      </div>
    `).join("");
  }

  const allSpends = document.getElementById("dashboard-recent-spends-full");
  if (allSpends) {
    allSpends.innerHTML = (state.dailySpends || []).map(s => `
      <div class="spend-row">
        <div class="spend-info">
          <strong>${s.title}</strong>
          <small>${s.date} • ${s.cat} • ${s.method}</small>
        </div>
        <div style="display: flex; align-items: center; gap: 0.75rem;">
          <strong class="spend-amount" style="color: var(--danger);">- ${fmt(s.amount)}</strong>
          <button class="btn-table-delete" onclick="deleteSpend('${s.id}')" title="Delete Spend">🗑️ Delete</button>
        </div>
      </div>
    `).join("");
  }

  // 9. Completed Payments Page
  renderCompletedPaymentsPage(metrics);

  // 10. Raw JSON Sync
  const jsonEditor = document.getElementById("cms-raw-json-editor");
  if (jsonEditor && document.activeElement !== jsonEditor) {
    jsonEditor.value = JSON.stringify(state, null, 2);
  }
}

function renderCompletedPaymentsPage(metrics) {
  const container = document.getElementById("completed-payments-container");
  if (!container) return;

  const paidFixed = (state.fixedPayments || []).filter(f => f.isPaid);
  const paidBnpl = (state.installments || []).filter(i => i.isPaid);
  const paidSubs = (state.subscriptions || []).filter(s => s.isPaid);
  const paidCards = (state.creditCards || []).filter(c => c.isPaid);
  const paidSpends = (state.dailySpends || []);
  const paidWishlist = (state.wishlist || []).filter(w => w.isPaid);

  const totalItemsCount = paidFixed.length + paidBnpl.length + paidSubs.length + paidCards.length + paidSpends.length + paidWishlist.length;

  container.innerHTML = `
    <div class="balance-card" style="background: linear-gradient(135deg, rgba(16, 185, 129, 0.2), rgba(99, 102, 241, 0.15)); border-color: var(--primary);">
      <div class="balance-card-header">
        <span>SETTLED PAYMENTS IN CURRENT CYCLE</span>
        <span class="badge badge-success">✅ ${totalItemsCount} Total Transactions Settled</span>
      </div>
      <div class="balance-amount" style="color: var(--primary-light);">${fmt(metrics.totalSettledAmount)}</div>
      <div class="balance-footer">
        <span>Remaining Pending Commitments: <strong>${fmt(metrics.totalPendingAmount)}</strong></span>
        <span>Total Committed Budget: <strong>${fmt(metrics.totalCommitted + metrics.totalDailySpent)}</strong></span>
      </div>
    </div>

    <div class="completed-cat-grid">
      <!-- 1. Fixed Bills -->
      <div class="completed-cat-card">
        <div class="card-head">
          <h3>🏠 Fixed Bills & Loans</h3>
          <span class="badge-source badge-source-fixed">${paidFixed.length} Settled</span>
        </div>
        <div class="spends-list">
          ${paidFixed.length ? paidFixed.map(f => `
            <div class="spend-row paid-row">
              <div class="spend-info">
                <strong class="item-title">${f.name}</strong>
                <small>${f.category} • Due: ${f.dueDay}th</small>
              </div>
              <div style="display: flex; align-items: center; gap: 0.5rem;">
                <strong>${fmt(f.amount)}</strong>
                <button class="btn-table-edit" onclick="togglePaymentStatus('fixed', '${f.id}')" title="Undo / Mark Unpaid">↩️</button>
              </div>
            </div>
          `).join("") : `<p class="text-muted" style="font-size: 0.85rem;">No fixed bills marked as paid.</p>`}
        </div>
      </div>

      <!-- 2. BNPL -->
      <div class="completed-cat-card">
        <div class="card-head">
          <h3>🛍️ BNPL & Installments</h3>
          <span class="badge-source badge-source-bnpl">${paidBnpl.length} Settled</span>
        </div>
        <div class="spends-list">
          ${paidBnpl.length ? paidBnpl.map(i => `
            <div class="spend-row paid-row">
              <div class="spend-info">
                <strong class="item-title">${i.item}</strong>
                <small>${i.platform} • ${i.member}</small>
              </div>
              <div style="display: flex; align-items: center; gap: 0.5rem;">
                <strong>${fmt(i.monthly)}</strong>
                <button class="btn-table-edit" onclick="togglePaymentStatus('bnpl', '${i.id}')" title="Undo / Mark Unpaid">↩️</button>
              </div>
            </div>
          `).join("") : `<p class="text-muted" style="font-size: 0.85rem;">No BNPL installments paid yet.</p>`}
        </div>
      </div>

      <!-- 3. Subscriptions -->
      <div class="completed-cat-card">
        <div class="card-head">
          <h3>📱 Subscriptions & Auto-Pay</h3>
          <span class="badge-source badge-source-sub">${paidSubs.length} Settled</span>
        </div>
        <div class="spends-list">
          ${paidSubs.length ? paidSubs.map(s => `
            <div class="spend-row paid-row">
              <div class="spend-info">
                <strong class="item-title">${s.name}</strong>
                <small>Billing: ${s.billingDay}th</small>
              </div>
              <div style="display: flex; align-items: center; gap: 0.5rem;">
                <strong>${fmt(s.amountLkr)}</strong>
                <button class="btn-table-edit" onclick="togglePaymentStatus('sub', '${s.id}')" title="Undo / Mark Unpaid">↩️</button>
              </div>
            </div>
          `).join("") : `<p class="text-muted" style="font-size: 0.85rem;">No subscriptions settled yet.</p>`}
        </div>
      </div>

      <!-- 4. Credit Cards -->
      <div class="completed-cat-card">
        <div class="card-head">
          <h3>💳 Credit Card Settlements</h3>
          <span class="badge-source badge-source-card">${paidCards.length} Settled</span>
        </div>
        <div class="spends-list">
          ${paidCards.length ? paidCards.map(c => `
            <div class="spend-row paid-row">
              <div class="spend-info">
                <strong class="item-title">${c.bank} (${c.name})</strong>
                <small>Statement Settlement</small>
              </div>
              <div style="display: flex; align-items: center; gap: 0.5rem;">
                <strong>${fmt(c.due)}</strong>
                <button class="btn-table-edit" onclick="togglePaymentStatus('card', '${c.id}')" title="Undo / Mark Unpaid">↩️</button>
              </div>
            </div>
          `).join("") : `<p class="text-muted" style="font-size: 0.85rem;">No credit cards marked paid.</p>`}
        </div>
      </div>

      <!-- 5. Wishlist Items -->
      <div class="completed-cat-card">
        <div class="card-head">
          <h3>✨ Wishlist Purchases</h3>
          <span class="badge-source badge-source-bnpl">${paidWishlist.length} Bought</span>
        </div>
        <div class="spends-list">
          ${paidWishlist.length ? paidWishlist.map(w => `
            <div class="spend-row paid-row">
              <div class="spend-info">
                <strong class="item-title">${w.item}</strong>
                <small>${w.category} • Priority: ${w.priority}</small>
              </div>
              <div style="display: flex; align-items: center; gap: 0.5rem;">
                <strong>${fmt(w.cost)}</strong>
                <button class="btn-table-edit" onclick="togglePaymentStatus('wishlist', '${w.id}')" title="Undo / Mark Unpaid">↩️</button>
              </div>
            </div>
          `).join("") : `<p class="text-muted" style="font-size: 0.85rem;">No wishlist items purchased yet.</p>`}
        </div>
      </div>

      <!-- 6. Daily Spends -->
      <div class="completed-cat-card">
        <div class="card-head">
          <h3>🛒 Daily Itemized Expenses</h3>
          <span class="badge-source badge-source-spend">${paidSpends.length} Logs</span>
        </div>
        <div class="spends-list">
          ${paidSpends.length ? paidSpends.map(s => `
            <div class="spend-row paid-row">
              <div class="spend-info">
                <strong class="item-title">${s.title}</strong>
                <small>${s.date} • ${s.cat} • ${s.method}</small>
              </div>
              <div style="display: flex; align-items: center; gap: 0.5rem;">
                <strong>${fmt(s.amount)}</strong>
                <button class="btn-table-delete" onclick="deleteSpend('${s.id}')" title="Delete Spend">🗑️</button>
              </div>
            </div>
          `).join("") : `<p class="text-muted" style="font-size: 0.85rem;">No daily spends logged.</p>`}
        </div>
      </div>
    </div>
  `;
}

function saveRawJsonEditor() {
  const editor = document.getElementById("cms-raw-json-editor");
  if (!editor) return;
  try {
    const parsed = JSON.parse(editor.value);
    state = parsed;
    persistState();
    renderApp();
    showToast("JSON Database successfully committed!", "success");
  } catch (err) {
    showToast("Invalid JSON syntax: " + err.message, "danger");
  }
}


// --- ITEM 3: WISHLIST / NEEDS PLANNER CATEGORY MANAGER ---
function openWishlistCategoryManager() {
  const cats = (state.wishlistCategories || defaultState.wishlistCategories)
    .sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));

  const html = `
    <div class="explainer-box" style="margin-bottom: 1rem;">
      <strong>💡 Tip:</strong> Add, rename, or delete categories here. They'll appear in the dropdown when adding any Needs Planner item.
    </div>
    <div id="wcat-list">
      ${cats.map(c => `
        <div class="spend-row" data-wcatid="${c.id}">
          <input type="text" class="form-control wcat-name-input" data-wcatid="${c.id}" value="${c.name}" style="flex: 1; max-width: 300px;">
          <button class="btn-table-delete" onclick="deleteWishlistCategory('${c.id}')">🗑️</button>
        </div>
      `).join('')}
    </div>
    <div style="margin-top: 1rem; display: flex; gap: 0.75rem; align-items: center;">
      <input type="text" id="new-wcat-name" class="form-control" placeholder="New category name..." style="flex: 1;">
      <button class="btn btn-primary btn-sm" onclick="addWishlistCategory()">➕ Add</button>
    </div>
  `;
  openModal("🗂️ Manage Needs Planner Categories", html, () => {
    // Save all name edits
    document.querySelectorAll(".wcat-name-input").forEach(input => {
      const id = input.dataset.wcatid;
      const cat = (state.wishlistCategories || []).find(c => c.id === id);
      if (cat) cat.name = input.value.trim() || cat.name;
    });
    persistState();
    renderApp();
    showToast("Needs Planner categories saved!", "success");
  });
}

function addWishlistCategory() {
  const nameEl = document.getElementById("new-wcat-name");
  const name = nameEl?.value.trim();
  if (!name) return;
  const maxOrder = Math.max(0, ...(state.wishlistCategories || []).map(c => c.sortOrder || 0));
  state.wishlistCategories = state.wishlistCategories || [];
  state.wishlistCategories.push({ id: "wc_" + Date.now(), name, sortOrder: maxOrder + 1 });
  persistState();
  // Refresh modal in place
  closeModal();
  setTimeout(() => openWishlistCategoryManager(), 100);
  showToast(`Added category: ${name}`, "success");
}

function deleteWishlistCategory(id) {
  state.wishlistCategories = (state.wishlistCategories || []).filter(c => c.id !== id);
  persistState();
  // Refresh modal in place
  closeModal();
  setTimeout(() => openWishlistCategoryManager(), 100);
  showToast("Category deleted", "success");
}

// --- ITEM 2: LOOKUP TABLE CRUD (BNPL PLATFORMS, FIXED BILL CATEGORIES) ---
function openBnplPlatformManager() {
  const platforms = state.bnplPlatforms || defaultState.bnplPlatforms;
  const html = `
    <div class="explainer-box" style="margin-bottom: 1rem;">
      <strong>💡</strong> Add a new BNPL platform (e.g. "Spathi") and it will immediately appear in the platform dropdown when adding any BNPL plan.
    </div>
    ${platforms.map(p => `
      <div class="spend-row">
        <input type="text" class="form-control bnpl-plat-input" data-platid="${p.id}" value="${p.name}" style="flex: 1; max-width: 200px;">
        <input type="color" class="form-control" data-platid-color="${p.id}" value="${p.color || '#10B981'}" style="width: 50px; height: 38px; padding: 2px;">
        <button class="btn-table-delete" onclick="deleteBnplPlatform('${p.id}')">🗑️</button>
      </div>
    `).join('')}
    <div style="margin-top: 1rem; display: flex; gap: 0.75rem; align-items: center;">
      <input type="text" id="new-plat-name" class="form-control" placeholder="New platform name..." style="flex: 1;">
      <button class="btn btn-primary btn-sm" onclick="addBnplPlatform()">➕ Add</button>
    </div>
  `;
  openModal("🛍️ Manage BNPL Platforms", html, () => {
    document.querySelectorAll(".bnpl-plat-input").forEach(input => {
      const id = input.dataset.platid;
      const plat = (state.bnplPlatforms || []).find(p => p.id === id);
      if (plat) plat.name = input.value.trim() || plat.name;
    });
    document.querySelectorAll("[data-platid-color]").forEach(input => {
      const id = input.dataset.platidColor;
      const plat = (state.bnplPlatforms || []).find(p => p.id === id);
      if (plat) plat.color = input.value;
    });
    persistState();
    showToast("BNPL platforms saved!", "success");
  });
}

function addBnplPlatform() {
  const name = document.getElementById("new-plat-name")?.value.trim();
  if (!name) return;
  state.bnplPlatforms = state.bnplPlatforms || [];
  state.bnplPlatforms.push({ id: "bp_" + Date.now(), name, color: "#6366F1" });
  persistState();
  closeModal();
  setTimeout(() => openBnplPlatformManager(), 100);
  showToast(`Added platform: ${name}`, "success");
}

function deleteBnplPlatform(id) {
  state.bnplPlatforms = (state.bnplPlatforms || []).filter(p => p.id !== id);
  persistState();
  closeModal();
  setTimeout(() => openBnplPlatformManager(), 100);
}

// --- ITEM 6: DATA-AWARE AI SNAPSHOT (NOT SELF-TRAINING - FRESH EVERY REQUEST) ---
function buildAiSnapshot(metrics) {
  // Assemble a complete, fresh snapshot of the household's current financial state.
  // This is sent to the AI with every request so advice is always based on real current numbers.
  const topCats = {};
  (state.dailySpends || []).forEach(s => {
    topCats[s.cat] = (topCats[s.cat] || 0) + s.amount;
  });
  const topCategories = Object.entries(topCats)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5)
    .map(([cat, amt]) => `${cat}: ${fmt(amt)}`);

  const pendingBnpl = (state.installments || [])
    .filter(i => !i.isPaid)
    .map(i => `${i.item} (${i.platform}): ${fmt(i.monthly)}/month, ${fmt(i.remaining)} remaining`);

  const pendingFixed = (state.fixedPayments || [])
    .filter(f => !f.isPaid)
    .map(f => `${f.name}: ${fmt(f.amount)}`);

  const cycleProgress = state.activeCycle?.daysRemaining 
    ? Math.round((1 - state.activeCycle.daysRemaining / 30) * 100)
    : 0;

  return {
    household_cycle: state.activeCycle?.name || "Current Cycle",
    cycle_progress_pct: cycleProgress,
    total_income: fmt(metrics.totalIncome),
    total_committed_outgoings: fmt(metrics.totalCommitted),
    total_daily_spent_so_far: fmt(metrics.totalDailySpent),
    remaining_spendable_balance: fmt(metrics.remainingBalance),
    projected_cycle_savings: fmt(metrics.projectedSavings),
    days_remaining: state.activeCycle?.daysRemaining || 26,
    daily_budget_remaining: fmt(Math.round(metrics.remainingBalance / (state.activeCycle?.daysRemaining || 26))),
    next_month_forecast: metrics.hasShortfall
      ? `⚠️ SHORTFALL: ${fmt(Math.abs(metrics.nextNetSurplus))} deficit predicted`
      : `✅ SURPLUS: ${fmt(metrics.nextNetSurplus)} projected`,
    safety_reserve_required: fmt(metrics.safetyReserveAmount),
    pending_bnpl_installments: pendingBnpl,
    pending_fixed_payments: pendingFixed,
    top_spending_categories: topCategories,
    planned_wishlist_deductions: fmt(metrics.totalPlannedWishlist),
    reserve_percentage_setting: `${metrics.reservePct}%`,
    members: (state.members || []).map(m => `${m.name} (${m.role}): ${fmt(m.salary)}`).join(", ")
  };
}

function buildAiPrompt(userQuestion, metrics) {
  const snapshot = buildAiSnapshot(metrics);
  const tone = state.aiSettings?.tone || "balanced";
  const toneInstruction = tone === "strict"
    ? "Be direct, no softening — point out risks and shortfalls plainly."
    : tone === "encouraging"
    ? "Be warm and encouraging, highlight wins before addressing concerns."
    : "Be balanced — clear about both positive trends and risks.";

  return `You are a household budget advisor. ${toneInstruction}

IMPORTANT RULES:
- Your response is NARRATIVE TEXT ONLY — do NOT produce calculation tables or override any numbers. The app's deterministic engine handles all math.
- Base your advice ENTIRELY on the real snapshot data below. If the snapshot shows a shortfall, say so.
- Keep response under 120 words.

=== LIVE HOUSEHOLD FINANCIAL SNAPSHOT (Current Cycle) ===
${JSON.stringify(snapshot, null, 2)}
=== END SNAPSHOT ===

User question or context: "${userQuestion || 'Give me a brief overall assessment of this cycle.'}"

Provide personalized, data-aware advice based solely on the above snapshot numbers.`;
}

async function getAiAdvice(userQuestion = "") {
  const outputEl = document.getElementById("ai-advice-text");
  const metrics = calculateMetrics();

  if (!state.aiSettings?.geminiKey && !state.aiSettings?.openaiKey) {
    // Rule-based fallback advice when no AI key configured
    const advice = metrics.hasShortfall
      ? `⚠️ Next month shows a projected shortfall of ${fmt(Math.abs(metrics.nextNetSurplus))}. Focus on cutting BNPL purchases and discretionary spend this cycle.`
      : `✅ You're on track this cycle. With ${fmt(metrics.remainingBalance)} remaining over ${state.activeCycle?.daysRemaining || 26} days, your daily safe budget is ${fmt(Math.round(metrics.remainingBalance / (state.activeCycle?.daysRemaining || 26)))}. Your ${metrics.reservePct}% safety reserve (${fmt(metrics.safetyReserveAmount)}) is well-funded.`;
    if (outputEl) outputEl.textContent = advice;
    return;
  }

  if (outputEl) outputEl.textContent = "⏳ Consulting AI advisor with your live household data...";

  const prompt = buildAiPrompt(userQuestion, metrics);
  const activeKey = state.aiSettings?.provider === "openai" ? state.aiSettings?.openaiKey : state.aiSettings?.geminiKey;

  try {
    let responseText = "";
    if (state.aiSettings?.provider === "openai") {
      const res = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: { "Content-Type": "application/json", "Authorization": `Bearer ${activeKey}` },
        body: JSON.stringify({
          model: state.aiSettings?.model || "gpt-4o-mini",
          messages: [{ role: "user", content: prompt }]
        })
      });
      const data = await res.json();
      responseText = data.choices?.[0]?.message?.content || "Unable to get response.";
    } else {
      const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${state.aiSettings?.model || 'gemini-1.5-flash'}:generateContent?key=${activeKey}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
      });
      const data = await res.json();
      responseText = data.candidates?.[0]?.content?.parts?.[0]?.text || "Unable to get response.";
    }
    if (outputEl) outputEl.textContent = responseText;
  } catch (err) {
    if (outputEl) outputEl.textContent = `❌ AI connection failed: ${err.message}. Using rule-based advice instead.`;
    await getAiAdvice(""); // fall back to rule-based
  }
}

// Override old testAiConnection to use the new snapshot-aware prompt
async function testAiConnection() {
  const outputEl = document.getElementById("ai-test-output");
  if (outputEl) outputEl.innerHTML = "<em>⏳ Building live data snapshot and sending to AI...</em>";
  const metrics = calculateMetrics();
  const activeKey = state.aiSettings?.provider === "openai" ? state.aiSettings?.openaiKey : state.aiSettings?.geminiKey;
  if (!activeKey) {
    const snapshot = buildAiSnapshot(metrics);
    if (outputEl) outputEl.innerHTML = `<strong style="color: var(--warning);">⚠️ No API key configured.</strong><br><br><strong>Live snapshot that WOULD be sent to AI:</strong><br><code style="font-size: 0.75rem; white-space: pre-wrap;">${JSON.stringify(snapshot, null, 2)}</code>`;
    return;
  }
  const prompt = buildAiPrompt("Give a one-paragraph summary of my current financial health.", metrics);
  try {
    let responseText = "";
    if (state.aiSettings?.provider === "openai") {
      const res = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: { "Content-Type": "application/json", "Authorization": `Bearer ${activeKey}` },
        body: JSON.stringify({ model: state.aiSettings?.model || "gpt-4o-mini", messages: [{ role: "user", content: prompt }] })
      });
      const data = await res.json();
      responseText = data.choices?.[0]?.message?.content || "No response.";
    } else {
      const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${state.aiSettings?.model || 'gemini-1.5-flash'}:generateContent?key=${activeKey}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
      });
      const data = await res.json();
      responseText = data.candidates?.[0]?.content?.parts?.[0]?.text || "No response.";
    }
    if (outputEl) outputEl.innerHTML = `<span style="color: var(--success);">✅ AI connected (data-aware snapshot sent):</span><br>${responseText}`;
  } catch (err) {
    if (outputEl) outputEl.innerHTML = `<span style="color: var(--danger);">❌ Connection Failed: ${err.message}</span>`;
  }
}

// --- ITEM 5: ANALYTICS DASHBOARD WITH CHART.JS ---
let analyticsCharts = {};

function renderAnalyticsDashboard() {
  const container = document.getElementById("analytics-container");
  if (!container) return;

  const metrics = calculateMetrics();
  const history = state.cycleHistory || defaultState.cycleHistory;

  // Spending by Category (current cycle daily spends)
  const catTotals = {};
  (state.dailySpends || []).forEach(s => {
    catTotals[s.cat] = (catTotals[s.cat] || 0) + s.amount;
  });
  const catLabels = Object.keys(catTotals);
  const catData = Object.values(catTotals);
  const catColors = catLabels.map((c, i) => {
    const match = (state.categories || []).find(cat => cat.name === c);
    return match ? match.color : `hsl(${(i * 60) % 360}, 70%, 60%)`;
  });

  container.innerHTML = `
    <!-- Summary row -->
    <div class="metrics-grid" style="margin-bottom: 1.5rem;">
      <div class="metric-card">
        <div class="metric-header"><span>Total Settled</span><span class="metric-icon">✅</span></div>
        <div class="metric-value" style="font-size: 1.3rem;">${fmt(metrics.totalSettledAmount)}</div>
        <div class="metric-sub">Payments settled this cycle</div>
      </div>
      <div class="metric-card">
        <div class="metric-header"><span>Daily Avg Spend</span><span class="metric-icon">📊</span></div>
        <div class="metric-value" style="font-size: 1.3rem;">${fmt(Math.round(metrics.totalDailySpent / Math.max(1, 30 - (state.activeCycle?.daysRemaining || 26))))}</div>
        <div class="metric-sub">Per day elapsed in cycle</div>
      </div>
      <div class="metric-card">
        <div class="metric-header"><span>Savings Rate</span><span class="metric-icon">💰</span></div>
        <div class="metric-value" style="font-size: 1.3rem; color: var(--primary-light);">${Math.round((metrics.projectedSavings / metrics.totalIncome) * 100)}%</div>
        <div class="metric-sub">Of total income projected saved</div>
      </div>
      <div class="metric-card">
        <div class="metric-header"><span>BNPL Burden</span><span class="metric-icon">🛍️</span></div>
        <div class="metric-value" style="font-size: 1.3rem; color: #FCD34D;">${Math.round((metrics.totalInstallments / metrics.totalIncome) * 100)}%</div>
        <div class="metric-sub">Of income goes to installments</div>
      </div>
    </div>

    <!-- Charts Grid -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(420px, 1fr)); gap: 1.5rem;">

      <!-- Chart 1: Cycle History - Income vs Committed vs Remaining -->
      <div class="section-card">
        <div class="card-header-flex">
          <h3>📈 Cycle Trend: Income vs Outgoings vs Balance</h3>
        </div>
        <canvas id="chart-cycle-trend" style="max-height: 240px;"></canvas>
      </div>

      <!-- Chart 2: Category Spending Breakdown -->
      <div class="section-card">
        <div class="card-header-flex">
          <h3>🛒 Current Cycle Spending by Category</h3>
        </div>
        <canvas id="chart-category-spend" style="max-height: 240px;"></canvas>
      </div>

      <!-- Chart 3: BNPL Payoff Progress -->
      <div class="section-card" style="grid-column: 1 / -1;">
        <div class="card-header-flex">
          <h3>🛍️ BNPL Installment Payoff Progress</h3>
          <p class="text-muted">Progress = amount paid vs total price</p>
        </div>
        <div id="chart-bnpl-bars">
          ${(state.installments || []).map(inst => {
            const paidAmt = inst.total - inst.remaining;
            const pct = Math.min(100, Math.round((paidAmt / inst.total) * 100));
            return `
              <div style="margin-bottom: 0.9rem;">
                <div style="display: flex; justify-content: space-between; margin-bottom: 0.25rem;">
                  <span style="font-size: 0.85rem; font-weight: 600;">${inst.item} <small style="color: var(--text-muted);">(${inst.member})</small></span>
                  <span style="font-size: 0.8rem; color: var(--primary-light);">${fmt(paidAmt)} / ${fmt(inst.total)} (${pct}%)</span>
                </div>
                <div style="background: rgba(255,255,255,0.08); border-radius: 999px; height: 8px; overflow: hidden;">
                  <div style="height: 100%; width: ${pct}%; background: linear-gradient(90deg, var(--primary), var(--primary-light)); border-radius: 999px; transition: width 0.5s ease;"></div>
                </div>
              </div>
            `;
          }).join('')}
        </div>
      </div>

      <!-- Chart 4: Savings Rate Trend -->
      <div class="section-card">
        <div class="card-header-flex">
          <h3>💰 Savings Rate Trend (per Cycle)</h3>
        </div>
        <canvas id="chart-savings-trend" style="max-height: 200px;"></canvas>
      </div>

    </div>
  `;

  // Draw Chart.js charts (loaded from CDN in HTML)
  if (typeof Chart !== "undefined") {
    // Destroy old instances to avoid canvas reuse errors
    Object.values(analyticsCharts).forEach(c => c.destroy());
    analyticsCharts = {};

    // Chart 1: Cycle Trend Line Chart
    analyticsCharts.trend = new Chart(document.getElementById("chart-cycle-trend"), {
      type: "line",
      data: {
        labels: history.map(h => h.cycle.split("–")[0].trim()),
        datasets: [
          { label: "Income", data: history.map(h => h.income), borderColor: "#10B981", tension: 0.35, fill: false, pointRadius: 4 },
          { label: "Committed Outgoings", data: history.map(h => h.committed), borderColor: "#F59E0B", tension: 0.35, fill: false, pointRadius: 4 },
          { label: "Remaining Balance", data: history.map(h => h.saved), borderColor: "#6366F1", tension: 0.35, fill: true, backgroundColor: "rgba(99,102,241,0.08)", pointRadius: 4 }
        ]
      },
      options: {
        responsive: true,
        plugins: { legend: { labels: { color: "#9CA3AF", font: { size: 11 } } } },
        scales: {
          x: { ticks: { color: "#9CA3AF" }, grid: { color: "rgba(255,255,255,0.04)" } },
          y: { ticks: { color: "#9CA3AF", callback: v => `${Math.round(v/1000)}k` }, grid: { color: "rgba(255,255,255,0.04)" } }
        }
      }
    });

    // Chart 2: Category Spend Doughnut
    if (catLabels.length > 0) {
      analyticsCharts.category = new Chart(document.getElementById("chart-category-spend"), {
        type: "doughnut",
        data: { labels: catLabels, datasets: [{ data: catData, backgroundColor: catColors, borderWidth: 2, borderColor: "rgba(0,0,0,0.15)" }] },
        options: {
          responsive: true,
          plugins: { legend: { position: "right", labels: { color: "#9CA3AF", font: { size: 10 }, padding: 8 } } }
        }
      });
    }

    // Chart 4: Savings Rate Trend
    analyticsCharts.savings = new Chart(document.getElementById("chart-savings-trend"), {
      type: "bar",
      data: {
        labels: history.map(h => h.cycle.split("–")[0].trim()),
        datasets: [{
          label: "Savings Rate %",
          data: history.map(h => Math.round((h.saved / h.income) * 100)),
          backgroundColor: history.map(h => {
            const pct = (h.saved / h.income) * 100;
            return pct > 25 ? "rgba(16,185,129,0.7)" : pct > 15 ? "rgba(245,158,11,0.7)" : "rgba(239,68,68,0.7)";
          }),
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { labels: { color: "#9CA3AF", font: { size: 11 } } } },
        scales: {
          x: { ticks: { color: "#9CA3AF" }, grid: { color: "rgba(255,255,255,0.04)" } },
          y: { ticks: { color: "#9CA3AF", callback: v => v + "%" }, grid: { color: "rgba(255,255,255,0.04)" } }
        }
      }
    });
  }
}

// ============================================================
// SUPABASE CLOUD TAB — Live connection test (fixes black screen)
// ============================================================
async function testSupabaseConnection() {
  const outputEl = document.getElementById("supabase-test-output");
  const indicator = document.getElementById("supabase-sync-indicator");
  if (!outputEl) return;
  outputEl.innerHTML = `<em style="color:var(--text-muted);">⏳ Testing Supabase connection...</em>`;
  if (indicator) indicator.textContent = "⏳ Testing...";
  try {
    if (typeof loadFromSupabase !== "function") {
      outputEl.innerHTML = `<span style="color:var(--danger);">❌ supabase_sync.js not loaded. Check console for errors.</span>`;
      return;
    }
    const data = await loadFromSupabase();
    const hasData = data && Object.keys(data).length > 0;
    const memberCount = data?.members?.length || 0;
    const lastUpdated = data?.updatedAt || "Unknown";
    outputEl.innerHTML = hasData
      ? `<span style="color:var(--success);">✅ Supabase connected and responding!</span><br>
         <small style="color:var(--text-muted);">
           Cloud record found • ${memberCount} member(s) in cloud<br>
           Project: <code>bwavzxjyrrbfhuhtwjpt.supabase.co</code>
         </small>`
      : `<span style="color:var(--warning);">⚠️ Connected but cloud is empty (no household state found).</span><br>
         <small style="color:var(--text-muted);">This is normal on a fresh start. Push your local data to cloud using "Force Push to Cloud" below.</small>`;
    if (indicator) indicator.textContent = hasData ? "✅ Cloud sync active" : "⚠️ Cloud empty";
  } catch (err) {
    if (outputEl) outputEl.innerHTML = `<span style="color:var(--danger);">❌ Connection failed: ${err.message}</span>`;
    if (indicator) indicator.textContent = "❌ Sync error";
  }
}

// ============================================================
// SPEND CALENDAR — Monthly grid with clickable day cells
// ============================================================
let calendarViewDate = new Date();

function renderCalendarView(date) {
  if (date) calendarViewDate = date;
  const container = document.getElementById("calendar-container");
  const labelEl = document.getElementById("cal-month-label");
  if (!container) return;

  const metrics = calculateMetrics();
  const dailyBudget = Math.round(metrics.remainingBalance / Math.max(1, state.activeCycle?.daysRemaining || 26));
  const year = calendarViewDate.getFullYear();
  const month = calendarViewDate.getMonth();
  const today = new Date();

  if (labelEl) labelEl.textContent = calendarViewDate.toLocaleDateString("en-US", { month: "long", year: "numeric" });

  // Build spend map: { "2026-08-25": 6802, ... }
  const spendMap = {};
  (state.dailySpends || []).forEach(s => {
    if (!spendMap[s.date]) spendMap[s.date] = 0;
    spendMap[s.date] += s.amount;
  });

  // Calendar grid
  const firstDay = new Date(year, month, 1).getDay(); // 0=Sun
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const cycleStart = state.household?.cycleStartDay || 25;

  const dayLabels = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
  let html = `
    <div style="display:grid; grid-template-columns: repeat(7,1fr); gap:4px; margin-bottom:0.5rem;">
      ${dayLabels.map(d => `<div style="text-align:center;font-size:0.72rem;color:var(--text-muted);font-weight:600;padding:0.25rem;">${d}</div>`).join('')}
    </div>
    <div style="display:grid; grid-template-columns: repeat(7,1fr); gap:4px;">
      ${Array(firstDay).fill('<div></div>').join('')}
  `;

  for (let d = 1; d <= daysInMonth; d++) {
    const dateStr = `${year}-${String(month+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
    const daySpend = spendMap[dateStr] || 0;
    const isToday = today.getFullYear()===year && today.getMonth()===month && today.getDate()===d;
    const isCycleDay = d === cycleStart;
    const pct = dailyBudget > 0 ? (daySpend / dailyBudget) * 100 : 0;
    const dotColor = daySpend === 0 ? "transparent" : pct < 70 ? "#10B981" : pct < 100 ? "#F59E0B" : "#EF4444";
    const bgColor = isToday ? "rgba(99,102,241,0.25)" : isCycleDay ? "rgba(16,185,129,0.12)" : "rgba(255,255,255,0.04)";
    const border = isToday ? "1px solid #6366F1" : isCycleDay ? "1px solid rgba(16,185,129,0.3)" : "1px solid rgba(255,255,255,0.06)";

    html += `
      <div onclick="showCalendarDayDetail('${dateStr}')" style="
        background:${bgColor}; border:${border}; border-radius:8px;
        padding:0.4rem 0.3rem; cursor:pointer; min-height:56px;
        transition:background 0.15s ease; position:relative;
        display:flex; flex-direction:column; align-items:center; justify-content:flex-start;
      " onmouseover="this.style.background='rgba(99,102,241,0.15)'" onmouseout="this.style.background='${bgColor}'">
        <span style="font-size:0.75rem; font-weight:${isToday?'800':'500'}; color:${isToday?'#818CF8':'#E5E7EB'};">${d}</span>
        ${daySpend > 0 ? `
          <span style="width:8px;height:8px;border-radius:50%;background:${dotColor};margin-top:3px;display:block;"></span>
          <span style="font-size:0.62rem;color:${dotColor};margin-top:2px;font-weight:600;">${Math.round(daySpend/1000)}k</span>
        ` : ''}
        ${isCycleDay ? `<span style="font-size:0.55rem;color:#10B981;font-weight:700;margin-top:auto;">CYCLE</span>` : ''}
      </div>
    `;
  }

  html += `</div>`;
  container.innerHTML = html;
}

function changeCalendarMonth(delta) {
  calendarViewDate.setMonth(calendarViewDate.getMonth() + delta);
  renderCalendarView();
  // Hide day detail when month changes
  const detail = document.getElementById("calendar-day-detail");
  if (detail) detail.style.display = "none";
}

function showCalendarDayDetail(dateStr) {
  const detail = document.getElementById("calendar-day-detail");
  if (!detail) return;
  const daySpends = (state.dailySpends || []).filter(s => s.date === dateStr);
  const total = daySpends.reduce((sum,s) => sum+s.amount, 0);
  const dateDisplay = new Date(dateStr + "T12:00:00").toLocaleDateString("en-US", {weekday:"long",year:"numeric",month:"long",day:"numeric"});

  detail.style.display = "block";
  detail.innerHTML = `
    <div class="section-card">
      <div class="card-header-flex">
        <div>
          <h3>📅 ${dateDisplay}</h3>
          <p class="text-muted">${daySpends.length} transaction(s) — Total: <strong style="color:var(--primary-light);">${fmt(total)}</strong></p>
        </div>
        <button onclick="this.closest('#calendar-day-detail').style.display='none'" class="btn btn-secondary btn-sm">✕ Close</button>
      </div>
      ${daySpends.length ? `
        <div class="spends-list" style="margin-top:0.75rem;">
          ${daySpends.map(s => `
            <div class="spend-row" style="padding:0.5rem 0.75rem;">
              <div class="spend-info">
                <strong>${s.title}</strong>
                <small>${s.cat} • ${s.method}${s.memberName ? ' • ' + s.memberName : ''}</small>
              </div>
              <strong style="color:var(--primary-light);">${fmt(s.amount)}</strong>
            </div>
          `).join('')}
        </div>
      ` : `<p style="color:var(--text-muted);padding:1rem;text-align:center;">No spends logged on this date.</p>`}
    </div>
  `;
  detail.scrollIntoView({ behavior: "smooth", block: "nearest" });
}

// ============================================================
// DAILY SPEND ALERT — Smart notification when over budget
// ============================================================
function checkDailySpendAlert() {
  const metrics = calculateMetrics();
  const dailyBudget = Math.round(metrics.remainingBalance / Math.max(1, state.activeCycle?.daysRemaining || 26));
  const today = new Date().toISOString().split("T")[0];
  const todaySpend = (state.dailySpends || [])
    .filter(s => s.date === today)
    .reduce((sum, s) => sum + s.amount, 0);

  const pct = dailyBudget > 0 ? (todaySpend / dailyBudget) * 100 : 0;
  const banner = document.getElementById("spend-alert-banner");
  const badge = document.getElementById("ai-chat-badge");

  if (pct >= 100 && dailyBudget > 0) {
    const overBy = todaySpend - dailyBudget;
    if (banner) {
      banner.style.display = "block";
      banner.innerHTML = `⚠️ <strong>Over daily budget!</strong> You've spent ${fmt(todaySpend)} today (limit: ${fmt(dailyBudget)}). That's ${fmt(overBy)} over your safe daily limit.`;
    }
    if (badge) { badge.style.display = "flex"; }
  } else if (pct >= 70 && dailyBudget > 0) {
    if (banner) {
      banner.style.display = "block";
      banner.innerHTML = `🟡 <strong>Near daily limit.</strong> You've spent ${fmt(todaySpend)} of your ${fmt(dailyBudget)} daily budget (${Math.round(pct)}%). Spend carefully!`;
      banner.style.background = "rgba(245,158,11,0.1)";
      banner.style.color = "#FCD34D";
      banner.style.borderBottomColor = "rgba(245,158,11,0.3)";
    }
    if (badge) { badge.style.display = "flex"; }
  } else {
    if (banner) banner.style.display = "none";
    if (badge) badge.style.display = "none";
  }
}

// ============================================================
// AI CHAT WIDGET — Floating financial advisor chatbot
// ============================================================
let aiChatOpen = false;

function toggleAiChat() {
  aiChatOpen = !aiChatOpen;
  const panel = document.getElementById("ai-chat-panel");
  if (panel) {
    panel.style.display = aiChatOpen ? "flex" : "none";
    panel.style.flexDirection = "column";
  }
  if (aiChatOpen) {
    checkDailySpendAlert();
    const statusEl = document.getElementById("ai-chat-status");
    if (statusEl) {
      const hasKey = !!(state.aiSettings?.geminiKey || state.aiSettings?.openaiKey);
      statusEl.textContent = hasKey ? `Powered by ${state.aiSettings.provider === "openai" ? "OpenAI" : "Gemini"}` : "Rule-based (set key in Admin → AI Studio)";
    }
    const input = document.getElementById("ai-chat-input");
    if (input) setTimeout(() => input.focus(), 100);
  }
}

async function sendChatMessage() {
  const input = document.getElementById("ai-chat-input");
  const question = input?.value.trim();
  if (!question) return;
  input.value = "";
  appendChatMessage(question, "user");
  await processChatQuestion(question);
}

async function askQuickQuestion(question) {
  if (!aiChatOpen) toggleAiChat();
  appendChatMessage(question, "user");
  await processChatQuestion(question);
}

function appendChatMessage(text, role) {
  const container = document.getElementById("ai-chat-messages");
  if (!container) return;
  const isUser = role === "user";
  const div = document.createElement("div");
  div.style.cssText = `
    ${isUser
      ? "background:rgba(99,102,241,0.2);border:1px solid rgba(99,102,241,0.3);border-radius:12px 12px 0 12px;margin-left:auto;max-width:85%;"
      : "background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.1);border-radius:12px 12px 12px 0;max-width:95%;"}
    padding:0.65rem 0.9rem; font-size:0.83rem; color:#E5E7EB; line-height:1.5;
  `;
  div.textContent = text;
  container.appendChild(div);
  container.scrollTop = container.scrollHeight;
}

function appendChatThinking() {
  const container = document.getElementById("ai-chat-messages");
  if (!container) return null;
  const div = document.createElement("div");
  div.id = "chat-thinking-bubble";
  div.style.cssText = "background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.1);border-radius:12px 12px 12px 0;padding:0.65rem 0.9rem;font-size:0.83rem;color:var(--text-muted);";
  div.innerHTML = "⏳ <em>Thinking...</em>";
  container.appendChild(div);
  container.scrollTop = container.scrollHeight;
  return div;
}

async function processChatQuestion(question) {
  const thinkingEl = appendChatThinking();
  const metrics = calculateMetrics();
  let responseText = "";

  try {
    if (state.aiSettings?.geminiKey || state.aiSettings?.openaiKey) {
      // Real AI response
      const prompt = buildAiPrompt(question, metrics);
      const activeKey = state.aiSettings?.provider === "openai" ? state.aiSettings?.openaiKey : state.aiSettings?.geminiKey;
      if (state.aiSettings?.provider === "openai") {
        const res = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "Content-Type": "application/json", "Authorization": `Bearer ${activeKey}` },
          body: JSON.stringify({ model: state.aiSettings?.model || "gpt-4o-mini", messages: [{ role: "user", content: prompt }] })
        });
        const data = await res.json();
        responseText = data.choices?.[0]?.message?.content || "Unable to get response.";
      } else {
        const model = state.aiSettings?.model || "gemini-2.0-flash";
        const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${activeKey}`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
        });
        const data = await res.json();
        responseText = data.candidates?.[0]?.content?.parts?.[0]?.text || "Unable to get response.";
      }
    } else {
      // Rule-based fallback
      const lower = question.toLowerCase();
      const dailyBudget = Math.round(metrics.remainingBalance / Math.max(1, state.activeCycle?.daysRemaining || 26));
      if (lower.includes("today") || lower.includes("spend today")) {
        const today = new Date().toISOString().split("T")[0];
        const todaySpend = (state.dailySpends || []).filter(s => s.date === today).reduce((sum,s)=>sum+s.amount,0);
        responseText = `Your safe daily budget is ${fmt(dailyBudget)}. You've spent ${fmt(todaySpend)} today (${Math.round((todaySpend/Math.max(1,dailyBudget))*100)}% used). ${todaySpend > dailyBudget ? "⚠️ You're over today's safe limit!" : "✅ You're within budget!"}`;
      } else if (lower.includes("balance") || lower.includes("remaining")) {
        responseText = `Your remaining spendable balance is ${fmt(metrics.remainingBalance)}. Projected savings at cycle end: ${fmt(metrics.projectedSavings)}.`;
      } else if (lower.includes("bnpl") || lower.includes("koko") || lower.includes("installment")) {
        const pending = (state.installments || []).filter(i => !i.isPaid);
        responseText = pending.length ? `You have ${pending.length} pending BNPL installment(s) totalling ${fmt(pending.reduce((s,i)=>s+i.monthly,0))} this cycle.` : `No pending BNPL installments this cycle! ✅`;
      } else if (lower.includes("buy") || lower.includes("purchase")) {
        responseText = metrics.remainingBalance > 10000 ? `With ${fmt(metrics.remainingBalance)} remaining and ${state.activeCycle?.daysRemaining || 26} days left, you can afford moderate purchases. Consider your daily safe limit of ${fmt(dailyBudget)}/day first.` : `⚠️ Your remaining balance (${fmt(metrics.remainingBalance)}) is getting low. I'd wait before making any large purchases.`;
      } else {
        responseText = `I can see your household currently has ${fmt(metrics.remainingBalance)} remaining balance with ${state.activeCycle?.daysRemaining || 26} days left. Your daily safe spend limit is ${fmt(dailyBudget)}. ${metrics.hasShortfall ? "⚠️ Next month looks tight." : "✅ Next month looks healthy."}\n\n💡 Tip: Add your Gemini API key in Admin CMS → AI Advisor Studio for intelligent personalized advice!`;
      }
    }
  } catch (err) {
    responseText = `❌ Error: ${err.message}. Check your API key in Admin → AI Advisor Studio.`;
  }

  if (thinkingEl) thinkingEl.remove();
  appendChatMessage(responseText, "ai");
}

// ============================================================
// 3D INTERACTIVE THREE.JS HERO ANIMATION
// ============================================================
let threeScene, threeCamera, threeRenderer, threeAnimationId;
let threeObjects = [];

function initThreeHeroScene() {
  const canvas = document.getElementById("three-hero-canvas");
  if (!canvas || typeof THREE === "undefined") return;

  const container = canvas.parentElement;
  const width = container.clientWidth || 800;
  const height = container.clientHeight || 220;

  // Scene & Camera
  threeScene = new THREE.Scene();
  threeCamera = new THREE.PerspectiveCamera(50, width / height, 0.1, 1000);
  threeCamera.position.z = 18;

  // Renderer
  threeRenderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
  threeRenderer.setSize(width, height);
  threeRenderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

  // Lights
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
  threeScene.add(ambientLight);

  const pointLight1 = new THREE.PointLight(0x10B981, 2, 50); // Emerald light
  pointLight1.position.set(10, 10, 10);
  threeScene.add(pointLight1);

  const pointLight2 = new THREE.PointLight(0x6366F1, 2, 50); // Indigo light
  pointLight2.position.set(-10, -10, 10);
  threeScene.add(pointLight2);

  const pointLightGold = new THREE.PointLight(0xF59E0B, 2.5, 40); // Gold light
  pointLightGold.position.set(0, 5, 8);
  threeScene.add(pointLightGold);

  threeObjects = [];

  // 1. Central 3D Golden Coin Mesh
  const coinGeo = new THREE.CylinderGeometry(2.4, 2.4, 0.45, 32);
  const coinMat = new THREE.MeshStandardMaterial({
    color: 0xF59E0B,
    metalness: 0.85,
    roughness: 0.25,
    emissive: 0x78350F,
    emissiveIntensity: 0.2
  });
  const coinMesh = new THREE.Mesh(coinGeo, coinMat);
  coinMesh.rotation.x = Math.PI / 3;
  coinMesh.rotation.z = Math.PI / 6;
  coinMesh.position.set(6, 0.5, 0);
  threeScene.add(coinMesh);
  threeObjects.push({ mesh: coinMesh, rotSpeedX: 0.008, rotSpeedY: 0.015, floatSpeed: 0.002, basePos: { x: 6, y: 0.5, z: 0 } });

  // 2. Glowing Emerald Crystal Node (Wealth Buffer)
  const crystalGeo1 = new THREE.IcosahedronGeometry(1.4, 0);
  const crystalMat1 = new THREE.MeshStandardMaterial({
    color: 0x10B981,
    metalness: 0.6,
    roughness: 0.2,
    wireframe: false,
    emissive: 0x064E3B,
    emissiveIntensity: 0.4
  });
  const crystal1 = new THREE.Mesh(crystalGeo1, crystalMat1);
  crystal1.position.set(11, -1.5, -2);
  threeScene.add(crystal1);
  threeObjects.push({ mesh: crystal1, rotSpeedX: 0.012, rotSpeedY: 0.009, floatSpeed: 0.003, basePos: { x: 11, y: -1.5, z: -2 } });

  // 3. Indigo Polyhedron Node (Forecast AI)
  const crystalGeo2 = new THREE.OctahedronGeometry(1.2, 0);
  const crystalMat2 = new THREE.MeshStandardMaterial({
    color: 0x818CF8,
    metalness: 0.5,
    roughness: 0.3,
    emissive: 0x312E81,
    emissiveIntensity: 0.35
  });
  const crystal2 = new THREE.Mesh(crystalGeo2, crystalMat2);
  crystal2.position.set(2, 2.2, -3);
  threeScene.add(crystal2);
  threeObjects.push({ mesh: crystal2, rotSpeedX: 0.007, rotSpeedY: 0.018, floatSpeed: 0.0025, basePos: { x: 2, y: 2.2, z: -3 } });

  // 4. Particle Constellation Wave (250+ floating nodes)
  const particleCount = 280;
  const particleGeo = new THREE.BufferGeometry();
  const positions = new Float32Array(particleCount * 3);
  const colors = new Float32Array(particleCount * 3);

  const col1 = new THREE.Color(0x10B981);
  const col2 = new THREE.Color(0x6366F1);
  const col3 = new THREE.Color(0xF59E0B);

  for (let i = 0; i < particleCount * 3; i += 3) {
    positions[i] = (Math.random() - 0.5) * 45;
    positions[i + 1] = (Math.random() - 0.5) * 20;
    positions[i + 2] = (Math.random() - 0.5) * 25;

    const chosenCol = Math.random() < 0.4 ? col1 : Math.random() < 0.7 ? col2 : col3;
    colors[i] = chosenCol.r;
    colors[i + 1] = chosenCol.g;
    colors[i + 2] = chosenCol.b;
  }

  particleGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  particleGeo.setAttribute('color', new THREE.BufferAttribute(colors, 3));

  const particleMat = new THREE.PointsMaterial({
    size: 0.18,
    vertexColors: true,
    transparent: true,
    opacity: 0.85
  });

  const particleSystem = new THREE.Points(particleGeo, particleMat);
  threeScene.add(particleSystem);

  // Mouse Parallax
  let mouseX = 0, mouseY = 0;
  let targetX = 0, targetY = 0;

  window.addEventListener('mousemove', (e) => {
    mouseX = (e.clientX / window.innerWidth - 0.5) * 2;
    mouseY = (e.clientY / window.innerHeight - 0.5) * 2;
  });

  // Animation Loop
  let clock = new THREE.Clock();

  function animate() {
    threeAnimationId = requestAnimationFrame(animate);
    const elapsedTime = clock.getElapsedTime();

    // Smooth camera mouse parallax
    targetX += (mouseX * 2.5 - targetX) * 0.05;
    targetY += (-mouseY * 1.5 - targetY) * 0.05;
    threeCamera.position.x = targetX;
    threeCamera.position.y = targetY;
    threeCamera.lookAt(threeScene.position);

    // Rotate and float meshes
    threeObjects.forEach((obj, idx) => {
      obj.mesh.rotation.x += obj.rotSpeedX;
      obj.mesh.rotation.y += obj.rotSpeedY;
      obj.mesh.position.y = obj.basePos.y + Math.sin(elapsedTime * 1.5 + idx * 2) * 0.4;
    });

    // Particle wave drift
    particleSystem.rotation.y = elapsedTime * 0.03;
    particleSystem.rotation.x = Math.sin(elapsedTime * 0.02) * 0.1;

    threeRenderer.render(threeScene, threeCamera);
  }

  animate();

  // Resize listener
  window.addEventListener('resize', () => {
    if (!canvas || !container) return;
    const newW = container.clientWidth || 800;
    const newH = container.clientHeight || 220;
    threeCamera.aspect = newW / newH;
    threeCamera.updateProjectionMatrix();
    threeRenderer.setSize(newW, newH);
  });
}

// ============================================================
// DRAGGABLE & RESIZABLE AI CHATBOT WIDGET
// ============================================================
let aiChatScale = 1.0;

function resizeAiChat(delta) {
  aiChatScale = Math.max(0.8, Math.min(1.4, aiChatScale + delta * 0.1));
  const panel = document.getElementById("ai-chat-panel");
  if (panel) {
    panel.style.transform = `scale(${aiChatScale})`;
    panel.style.transformOrigin = "bottom right";
  }
}

function initDraggableAiChat() {
  const widget = document.getElementById("ai-chat-widget");
  const dragBar = document.getElementById("ai-chat-drag-bar");
  const fab = document.getElementById("ai-chat-fab");
  if (!widget) return;

  let isDragging = false;
  let startX, startY, initialLeft, initialTop;

  const onDragStart = (e) => {
    // Only drag if on drag bar or fab button
    const target = e.target;
    if (target.closest('.ai-chat-scale-btn') || target.tagName === 'INPUT' || target.tagName === 'BUTTON') {
      if (target !== fab && !target.closest('#ai-chat-fab')) return;
    }
    isDragging = true;
    const clientX = e.type.includes('touch') ? e.touches[0].clientX : e.clientX;
    const clientY = e.type.includes('touch') ? e.touches[0].clientY : e.clientY;

    const rect = widget.getBoundingClientRect();
    startX = clientX;
    startY = clientY;
    initialLeft = rect.left;
    initialTop = rect.top;

    widget.style.bottom = 'auto';
    widget.style.right = 'auto';
    widget.style.left = `${initialLeft}px`;
    widget.style.top = `${initialTop}px`;
  };

  const onDragMove = (e) => {
    if (!isDragging) return;
    e.preventDefault();
    const clientX = e.type.includes('touch') ? e.touches[0].clientX : e.clientX;
    const clientY = e.type.includes('touch') ? e.touches[0].clientY : e.clientY;

    const dx = clientX - startX;
    const dy = clientY - startY;

    const newLeft = Math.max(10, Math.min(window.innerWidth - widget.offsetWidth - 10, initialLeft + dx));
    const newTop = Math.max(10, Math.min(window.innerHeight - widget.offsetHeight - 10, initialTop + dy));

    widget.style.left = `${newLeft}px`;
    widget.style.top = `${newTop}px`;
  };

  const onDragEnd = () => {
    isDragging = false;
  };

  if (dragBar) {
    dragBar.addEventListener('mousedown', onDragStart);
    dragBar.addEventListener('touchstart', onDragStart, { passive: false });
  }

  if (fab) {
    fab.addEventListener('mousedown', onDragStart);
    fab.addEventListener('touchstart', onDragStart, { passive: false });
  }

  window.addEventListener('mousemove', onDragMove);
  window.addEventListener('touchmove', onDragMove, { passive: false });
  window.addEventListener('mouseup', onDragEnd);
  window.addEventListener('touchend', onDragEnd);
}

// Global DOM Bootstrap — loads from Supabase cloud on startup

document.addEventListener("DOMContentLoaded", async () => {
  // First render with local data for instant startup
  renderApp();

  // Initialize Three.js 3D Animated Hero Scene
  setTimeout(() => initThreeHeroScene(), 100);

  // Initialize Draggable AI Chatbot Widget
  initDraggableAiChat();

  // Then try to load from Supabase cloud (non-blocking)
  if (typeof loadFromSupabase === "function") {
    const cloudState = await loadFromSupabase();
    if (cloudState && Object.keys(cloudState).length > 0) {
      // Cloud has newer data — merge and re-render
      console.info("[App] Applying cloud state");
      state = {
        ...defaultState,
        ...cloudState,
        household: { ...defaultState.household, ...cloudState.household },
        uiComponents: { ...defaultState.uiComponents, ...cloudState.uiComponents },
        uiLabels: { ...defaultUiLabels, ...(cloudState.uiLabels || {}) },
        forecastSettings: { ...defaultState.forecastSettings, ...cloudState.forecastSettings },
        bnplPlatforms: (cloudState.bnplPlatforms && cloudState.bnplPlatforms.length) ? cloudState.bnplPlatforms : defaultState.bnplPlatforms,
        fixedBillCategories: (cloudState.fixedBillCategories && cloudState.fixedBillCategories.length) ? cloudState.fixedBillCategories : defaultState.fixedBillCategories,
        wishlistCategories: (cloudState.wishlistCategories && cloudState.wishlistCategories.length) ? cloudState.wishlistCategories : defaultState.wishlistCategories,
        cycleHistory: (cloudState.cycleHistory && cloudState.cycleHistory.length) ? cloudState.cycleHistory : defaultState.cycleHistory
      };
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
      renderApp(); // Re-render with cloud data
      showToast("☁️ Synced from cloud", "info");
    }
  }

  // Show first-run onboarding wizard if no members have been added yet
  // (delayed slightly so the render and cloud sync complete first)
  setTimeout(() => {
    if (isFirstRun()) {
      showFirstRunOnboarding();
    } else {
      checkDailySpendAlert(); // Check spend alert for returning users
    }
  }, 800);

  document.querySelectorAll(".nav-item").forEach(btn => {
    btn.addEventListener("click", () => {
      const tab = btn.dataset.tab;
      if (tab) switchTab(tab);
    });
  });
});

