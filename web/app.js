// ==============================================================================
// 100% DETERMINISTIC HOUSEHOLD BUDGET ENGINE & WORDPRESS-GRADE ADMIN CMS v4.5
// ==============================================================================

const STORAGE_KEY = "household_budget_master_db_v4_5";

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

  // Dashboard Page
  "page.dashboard.title": "Cycle Overview",
  "page.dashboard.subtitle": "Aug 25 – Sep 25, 2026 • 26 Days Remaining",
  "page.dashboard.balance_header": "REALTIME REMAINING SPENDABLE BALANCE",
  "page.dashboard.card_income": "Total Cycle Income",
  "page.dashboard.card_committed": "Committed Outgoings",
  "page.dashboard.card_spent": "Daily Spent so far",
  "page.dashboard.card_wishlist": "Planned Wishlist",
  "page.dashboard.breakdown_title": "Cycle Outgoings Breakdown",
  "page.dashboard.recent_spends_title": "Recent Daily Spends",

  // BNPL Page
  "page.bnpl.title": "BNPL & Koko Plans",
  "page.bnpl.subtitle": "Active installments, remaining balances, and monthly commitments.",
  "page.bnpl.active_heading": "Pending Installments (Current Cycle)",
  "page.bnpl.completed_heading": "Settled BNPL Installments in this Cycle",
  "page.bnpl.btn_add": "Add BNPL Plan",
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
  "page.fixed.btn_add": "Add Fixed Bill",

  // Needs Planner / Wishlist Page
  "page.wishlist.title": "Needs Planner & Wishlist",
  "page.wishlist.subtitle": "Categorized buy-list and needs planning prioritized for purchase.",
  "page.wishlist.active_heading": "Pending Needs & Items",
  "page.wishlist.completed_heading": "Purchased & Settled Items",
  "page.wishlist.btn_add": "Add Item to Plan",

  // Subscriptions Page
  "page.subs.title": "Subscriptions & Recurring Cards",
  "page.subs.subtitle": "Digital services, mobile packages, broadband routers, and cards.",
  "page.subs.btn_add": "Add Subscription",

  // Completed Page
  "page.completed.title": "Completed & Settled Payments",
  "page.completed.subtitle": "Master record of all payments settled in this cycle, organized by originating category.",

  // Buttons & Global
  "btn.log_spend": "Log Daily Spend",
  "btn.admin_cms": "Admin CMS"
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
    name: "Sathsara",
    email: "admin@homebudget.lk",
    role: "Administrator",
    avatar: "S"
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
  categories: [
    { id: "cat_1", name: "Groceries", color: "#10B981", monthlyBudget: 45000 },
    { id: "cat_2", name: "Transport / PickMe", color: "#F59E0B", monthlyBudget: 15000 },
    { id: "cat_3", name: "Food & Dining", color: "#EC4899", monthlyBudget: 25000 },
    { id: "cat_4", name: "Personal Care & Saloon", color: "#8B5CF6", monthlyBudget: 8000 },
    { id: "cat_5", name: "Health & Gym", color: "#06B6D4", monthlyBudget: 6000 },
    { id: "cat_6", name: "Other / Cash Reserve", color: "#64748B", monthlyBudget: 30000 }
  ],
  paymentMethods: [
    { id: "pm_1", name: "Cash", type: "cash" },
    { id: "pm_2", name: "Commercial Debit Card", type: "card" },
    { id: "pm_3", name: "Sampath Card", type: "card" },
    { id: "pm_4", name: "Fund Transfer", type: "bank" }
  ],
  aiSettings: {
    provider: "gemini",
    geminiKey: "",
    openaiKey: "",
    model: "gemini-1.5-flash",
    tone: "balanced",
    customPromptTemplate: ""
  },
  forecastSettings: {
    reservePercentage: 5.0,
    survivalBufferDays: 30,
    committedCategories: ["Housing", "Utilities", "Loan", "Insurance", "Telecom"]
  },
  members: [
    { id: "m1", name: "Sathsara", role: "husband", salary: 249585, color: "#10B981" },
    { id: "m2", name: "Dhiyan", role: "wife", salary: 150000, color: "#EC4899" }
  ],
  activeCycle: {
    name: "Aug 25 – Sep 25, 2026",
    daysRemaining: 26
  },
  incomes: [
    { id: "inc1", memberId: "m1", source: "Husband Salary", amount: 249585, date: "2026-08-24" },
    { id: "inc2", memberId: "m2", source: "Wife Salary", amount: 150000, date: "2026-08-25" }
  ],
  fixedPayments: [
    { id: "f1", name: "Apartment Rent", amount: 70000, dueDay: 25, category: "Housing", dest: "BOC Account", isPaid: true, paidDate: "2026-08-25" },
    { id: "f2", name: "Apartment ECB + Water", amount: 20000, dueDay: 25, category: "Utilities", dest: "BOC Account", isPaid: true, paidDate: "2026-08-25" },
    { id: "f3", name: "Commercial Bank Personal Loan", amount: 47544, dueDay: 26, category: "Loan", dest: "Combank", isPaid: true, paidDate: "2026-08-26" },
    { id: "f4", name: "Gold Loan Interest (Bracelet & Rings)", amount: 8500, dueDay: 26, category: "Loan", dest: "Combank", isPaid: false, paidDate: null }
  ],
  subscriptions: [
    { id: "s1", name: "Dialog Mobile", amountLkr: 2054, billingDay: 24, isPaid: true, paidDate: "2026-08-24" },
    { id: "s2", name: "Dialog Broadband Router", amountLkr: 5000, billingDay: 24, isPaid: false, paidDate: null },
    { id: "s3", name: "Office Phone Loan", amountLkr: 4500, billingDay: 24, isPaid: false, paidDate: null },
    { id: "s4", name: "Netflix Basic ($3.99)", amountLkr: 1400, billingDay: 24, isPaid: true, paidDate: "2026-08-24" },
    { id: "s5", name: "Apple Music ($3.29)", amountLkr: 1080, billingDay: 26, isPaid: true, paidDate: "2026-08-26" },
    { id: "s6", name: "Apple iCloud ($2.99)", amountLkr: 1000, billingDay: 26, isPaid: true, paidDate: "2026-08-26" },
    { id: "s7", name: "YouTube Premium", amountLkr: 1200, billingDay: 28, isPaid: false, paidDate: null }
  ],
  creditCards: [
    { id: "cc1", bank: "Commercial Bank", name: "Combank Platinum", due: 40000, isPaid: true, paidDate: "2026-08-25" },
    { id: "cc2", bank: "Sampath Bank", name: "Sampath Signature", due: 5000, isPaid: true, paidDate: "2026-08-25" },
    { id: "cc3", bank: "DFCC", name: "DFCC Visa", due: 0, isPaid: true, paidDate: "2026-08-25" }
  ],
  installments: [
    { id: "inst1", member: "Dhiyan", platform: "Koko", item: "Dinapala Group (Water Filter)", vendor: "Dinapala", total: 13647, monthly: 4549, remaining: 4549, isPaid: true, paidDate: "2026-08-25" },
    { id: "inst2", member: "Dhiyan", platform: "Koko", item: "Strong.lk (Supplements)", vendor: "Strong.lk", total: 14424, monthly: 4808, remaining: 4808, isPaid: true, paidDate: "2026-08-25" },
    { id: "inst3", member: "Dhiyan", platform: "Koko", item: "Dmart (Vacuum Cleaner)", vendor: "Dmart", total: 2850, monthly: 950, remaining: 950, isPaid: true, paidDate: "2026-08-25" },
    { id: "inst4", member: "Dhiyan", platform: "Koko", item: "Candy (Clothes)", vendor: "Candy", total: 5316, monthly: 1772, remaining: 1772, isPaid: true, paidDate: "2026-08-25" },
    { id: "inst5", member: "Sathsara", platform: "Koko", item: "Sensara (Perfume)", vendor: "Sensara", total: 16131, monthly: 5377, remaining: 10754, isPaid: false, paidDate: null },
    { id: "inst6", member: "Sathsara", platform: "Koko", item: "Deedat (Shirt)", vendor: "Deedat", total: 3990, monthly: 1330, remaining: 2660, isPaid: false, paidDate: null },
    { id: "inst7", member: "Sathsara", platform: "Mintpay", item: "Online Kade (Groceries 1)", vendor: "Online Kade", total: 16941, monthly: 5647, remaining: 5647, isPaid: true, paidDate: "2026-08-25" },
    { id: "inst8", member: "Sathsara", platform: "PayZy", item: "Beauty Harbour (Cosmetics)", vendor: "Beauty Harbour", total: 16500, monthly: 5500, remaining: 11000, isPaid: false, paidDate: null }
  ],
  wishlist: [
    { id: "w1", item: "Potato Smasher", category: "Kitchen", cost: 800, priority: "high", isPlanned: true, isPaid: false },
    { id: "w2", item: "Litro Gas Cylinder Refill", category: "Kitchen", cost: 4200, priority: "high", isPlanned: true, isPaid: false },
    { id: "w3", item: "Air Fryer / Convection Oven", category: "Kitchen", cost: 38000, priority: "medium", isPlanned: false, isPaid: false },
    { id: "w4", item: "New Bidet Shower Sprayer", category: "Bathroom", cost: 2800, priority: "high", isPlanned: true, isPaid: false },
    { id: "w5", item: "Floor Wiper", category: "Bathroom", cost: 1100, priority: "medium", isPlanned: true, isPaid: false },
    { id: "w6", item: "Spice Bottles Glass Set", category: "Kitchen", cost: 1500, priority: "low", isPlanned: false, isPaid: false }
  ],
  dailySpends: [
    { id: "d1", date: "2026-08-25", amount: 200, cat: "Health & Gym", method: "Cash", title: "Gym Pure Water", isPaid: true },
    { id: "d2", date: "2026-08-25", amount: 1400, cat: "Groceries", method: "Cash", title: "Chicken 1.1kg", isPaid: true },
    { id: "d3", date: "2026-08-25", amount: 6802, cat: "Groceries", method: "Commercial Debit Card", title: "Food City Groceries", isPaid: true },
    { id: "d4", date: "2026-08-25", amount: 406, cat: "Transport / PickMe", method: "Cash", title: "PickMe Tuk to Grocery", isPaid: true },
    { id: "d5", date: "2026-08-25", amount: 4100, cat: "Food & Dining", method: "Commercial Debit Card", title: "Spar Supermarket Beverages", isPaid: true },
    { id: "d6", date: "2026-08-26", amount: 10000, cat: "Other / Cash Reserve", method: "Fund Transfer", title: "Transfer to Wife Combank", isPaid: true },
    { id: "d7", date: "2026-08-26", amount: 4500, cat: "Other / Cash Reserve", method: "Cash", title: "ATM Cash Withdrawal", isPaid: true },
    { id: "d8", date: "2026-08-26", amount: 520, cat: "Personal Care & Saloon", method: "Cash", title: "Saloon Haircut & Grooming", isPaid: true }
  ]
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
        forecastSettings: { ...defaultState.forecastSettings, ...parsed.forecastSettings }
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
        <option value="Housing" ${isEdit && bill.category === 'Housing' ? 'selected' : ''}>Housing & Rent</option>
        <option value="Utilities" ${isEdit && bill.category === 'Utilities' ? 'selected' : ''}>Utilities (ECB/Water)</option>
        <option value="Loan" ${isEdit && bill.category === 'Loan' ? 'selected' : ''}>Bank Loan / Gold Loan</option>
        <option value="Insurance" ${isEdit && bill.category === 'Insurance' ? 'selected' : ''}>Insurance</option>
        <option value="Other" ${isEdit && bill.category === 'Other' ? 'selected' : ''}>Other Fixed</option>
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
        <option value="Koko" ${isEdit && inst.platform === 'Koko' ? 'selected' : ''}>Koko</option>
        <option value="Mintpay" ${isEdit && inst.platform === 'Mintpay' ? 'selected' : ''}>Mintpay</option>
        <option value="PayZy" ${isEdit && inst.platform === 'PayZy' ? 'selected' : ''}>PayZy</option>
        <option value="Other" ${isEdit && inst.platform === 'Other' ? 'selected' : ''}>Other BNPL</option>
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
      <label>Category</label>
      <input type="text" id="w-cat" class="form-control" value="${isEdit ? item.category : 'Kitchen'}">
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
  openModal(isEdit ? "Edit Wishlist Item" : "Add Wishlist Item", html, () => {
    const itemName = document.getElementById("w-name").value.trim();
    const category = document.getElementById("w-cat").value.trim();
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

// 7. Daily Spends
function openSpendModal() {
  const categoryOptions = (state.categories || defaultState.categories).map(c => `<option value="${c.name}">${c.name}</option>`).join('');
  const paymentOptions = (state.paymentMethods || defaultState.paymentMethods).map(p => `<option value="${p.name}">${p.name}</option>`).join('');

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
  `;
  openModal("Quick Log Daily Expense", html, () => {
    const amount = parseFloat(document.getElementById("qs-amt").value) || 0;
    const title = document.getElementById("qs-title").value.trim();
    const method = document.getElementById("qs-method").value;
    const cat = document.getElementById("qs-cat").value;

    if (amount <= 0 || !title) return showToast("Please enter amount and description", "danger");

    state.dailySpends.unshift({
      id: "d_" + Date.now(),
      date: new Date().toISOString().split("T")[0],
      amount,
      title,
      method,
      cat,
      isPaid: true
    });
    closeModal();
    persistState();
    renderApp();
    showToast(`Logged expense: ${fmt(amount)} for ${title}`, "success");
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
  showToast("AI Studio settings saved!", "success");
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
  customConfirm("Reset all database records back to Notebook Sample Data?", () => {
    state = JSON.parse(JSON.stringify(defaultState));
    persistState();
    renderApp();
    showToast("Reset to sample data", "info");
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

// Global DOM Bootstrap
document.addEventListener("DOMContentLoaded", () => {
  renderApp();

  document.querySelectorAll(".nav-item").forEach(btn => {
    btn.addEventListener("click", () => {
      const tab = btn.dataset.tab;
      if (tab) switchTab(tab);
    });
  });
});
