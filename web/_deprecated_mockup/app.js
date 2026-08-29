// ==============================================================================
// 100% DETERMINISTIC HOUSEHOLD BUDGET ENGINE & FULL CRUD APP CONTROLLER
// ==============================================================================

const STORAGE_KEY = "household_budget_db_v2";

// Default Initial State
const defaultState = {
  household: {
    name: "HomeBudget",
    logo: "💰",
    currency: "Rs.",
    cycleStartDay: 25,
    geminiApiKey: "",
    themePreset: "theme-emerald"
  },
  adminSetup: {
    hasAdminRegistered: true, // First-run check flag
    adminEmail: "admin@homebudget.lk"
  },
  currentUser: {
    name: "Sathsara",
    email: "admin@homebudget.lk",
    role: "husband",
    isAdmin: true
  },
  uiLabels: {
    nav_dashboard: "Dashboard",
    nav_daily_spends: "Daily Spends",
    nav_installments: "BNPL & Koko",
    nav_fixed_bills: "Fixed Bills & Loans",
    nav_forecast: "Survival Forecast",
    nav_wishlist: "Wishlist",
    nav_subscriptions: "Subscriptions",
    lbl_balance_header: "REALTIME REMAINING SPENDABLE BALANCE",
    lbl_dashboard_title: "Cycle Overview"
  },
  forecastSettings: {
    reservePercentage: 5.0, // 5% of income
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
    { id: "f1", name: "Apartment Rent", amount: 70000, dueDay: 25, category: "Housing", dest: "BOC Account", isPaid: true },
    { id: "f2", name: "Apartment ECB + Water", amount: 20000, dueDay: 25, category: "Utilities", dest: "BOC Account", isPaid: true },
    { id: "f3", name: "Commercial Bank Personal Loan", amount: 47544, dueDay: 26, category: "Loan", dest: "Combank", isPaid: true },
    { id: "f4", name: "Gold Loan Interest (Bracelet & Rings)", amount: 8500, dueDay: 26, category: "Loan", dest: "Combank", isPaid: false }
  ],
  subscriptions: [
    { id: "s1", name: "Dialog Mobile", amountLkr: 2054, billingDay: 24, isPaid: true },
    { id: "s2", name: "Dialog Broadband Router", amountLkr: 5000, billingDay: 24, isPaid: false },
    { id: "s3", name: "Office Phone Loan", amountLkr: 4500, billingDay: 24, isPaid: false },
    { id: "s4", name: "Netflix Basic ($3.99)", amountLkr: 1400, billingDay: 24, isPaid: true },
    { id: "s5", name: "Apple Music ($3.29)", amountLkr: 1080, billingDay: 26, isPaid: true },
    { id: "s6", name: "Apple iCloud ($2.99)", amountLkr: 1000, billingDay: 26, isPaid: true },
    { id: "s7", name: "YouTube Premium", amountLkr: 1200, billingDay: 28, isPaid: false }
  ],
  creditCards: [
    { id: "cc1", bank: "Commercial Bank", name: "Combank Platinum", due: 40000, isPaid: true },
    { id: "cc2", bank: "Sampath Bank", name: "Sampath Signature", due: 5000, isPaid: true },
    { id: "cc3", bank: "DFCC", name: "DFCC Visa", due: 0, isPaid: true }
  ],
  installments: [
    { id: "inst1", member: "Dhiyan", platform: "Koko", item: "Dinapala Group (Water Filter)", vendor: "Dinapala", total: 13647, monthly: 4549, remaining: 4549, isPaid: true },
    { id: "inst2", member: "Dhiyan", platform: "Koko", item: "Strong.lk (Supplements)", vendor: "Strong.lk", total: 14424, monthly: 4808, remaining: 4808, isPaid: true },
    { id: "inst3", member: "Dhiyan", platform: "Koko", item: "Dmart (Vacuum Cleaner)", vendor: "Dmart", total: 2850, monthly: 950, remaining: 950, isPaid: true },
    { id: "inst4", member: "Dhiyan", platform: "Koko", item: "Candy (Clothes)", vendor: "Candy", total: 5316, monthly: 1772, remaining: 1772, isPaid: true },
    { id: "inst5", member: "Sathsara", platform: "Koko", item: "Sensara (Perfume)", vendor: "Sensara", total: 16131, monthly: 5377, remaining: 10754, isPaid: false },
    { id: "inst6", member: "Sathsara", platform: "Koko", item: "Deedat (Shirt)", vendor: "Deedat", total: 3990, monthly: 1330, remaining: 2660, isPaid: false },
    { id: "inst7", member: "Sathsara", platform: "Mintpay", item: "Online Kade (Groceries 1)", vendor: "Online Kade", total: 16941, monthly: 5647, remaining: 5647, isPaid: true },
    { id: "inst8", member: "Sathsara", platform: "PayZy", item: "Beauty Harbour (Cosmetics)", vendor: "Beauty Harbour", total: 16500, monthly: 5500, remaining: 11000, isPaid: false }
  ],
  wishlist: [
    { id: "w1", item: "Potato Smasher", category: "Kitchen", cost: 800, priority: "high", isPlanned: true },
    { id: "w2", item: "Litro Gas Cylinder Refill", category: "Kitchen", cost: 4200, priority: "high", isPlanned: true },
    { id: "w3", item: "Air Fryer / Convection Oven", category: "Kitchen", cost: 38000, priority: "medium", isPlanned: false },
    { id: "w4", item: "New Bidet Shower Sprayer", category: "Bathroom", cost: 2800, priority: "high", isPlanned: true },
    { id: "w5", item: "Floor Wiper", category: "Bathroom", cost: 1100, priority: "medium", isPlanned: true },
    { id: "w6", item: "Spice Bottles Glass Set", category: "Kitchen", cost: 1500, priority: "low", isPlanned: false }
  ],
  dailySpends: [
    { id: "d1", date: "2026-08-25", amount: 200, cat: "Health & Gym", method: "Cash", title: "Gym Pure Water" },
    { id: "d2", date: "2026-08-25", amount: 1400, cat: "Groceries", method: "Cash", title: "Chicken 1.1kg" },
    { id: "d3", date: "2026-08-25", amount: 6802, cat: "Groceries", method: "Commercial Debit Card", title: "Food City Groceries" },
    { id: "d4", date: "2026-08-25", amount: 406, cat: "Transport / PickMe", method: "Cash", title: "PickMe Tuk to Grocery" },
    { id: "d5", date: "2026-08-25", amount: 4100, cat: "Food & Dining", method: "Commercial Debit Card", title: "Spar Supermarket Beverages" },
    { id: "d6", date: "2026-08-26", amount: 10000, cat: "Other / Cash Reserve", method: "Fund Transfer", title: "Transfer to Wife Combank" },
    { id: "d7", date: "2026-08-26", amount: 4500, cat: "Other / Cash Reserve", method: "Cash", title: "ATM Cash Withdrawal" },
    { id: "d8", date: "2026-08-26", amount: 520, cat: "Personal Care & Saloon", method: "Cash", title: "Saloon Haircut & Grooming" }
  ]
};

let state = loadSavedState();

function loadSavedState() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) return JSON.parse(saved);
  } catch (e) {}
  return JSON.parse(JSON.stringify(defaultState));
}

function persistState() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch (e) {}
}

// --- DETERMINISTIC ENGINE FORMULAS ---

function calculateMetrics() {
  const totalIncome = state.incomes.reduce((acc, i) => acc + i.amount, 0);
  const totalFixed = state.fixedPayments.reduce((acc, f) => acc + f.amount, 0);
  const totalInstallments = state.installments.reduce((acc, inst) => acc + inst.monthly, 0);
  const totalCreditCards = state.creditCards.reduce((acc, c) => acc + c.due, 0);
  const totalSubscriptions = state.subscriptions.reduce((acc, s) => acc + s.amountLkr, 0);

  const totalCommitted = totalFixed + totalInstallments + totalCreditCards + totalSubscriptions;

  let totalCash = 0;
  let totalCard = 0;
  for (const s of state.dailySpends) {
    if (s.method.toLowerCase().includes("cash")) {
      totalCash += s.amount;
    } else {
      totalCard += s.amount;
    }
  }
  const totalSpent = totalCash + totalCard;

  const totalPlannedWishlist = state.wishlist
    .filter(w => w.isPlanned)
    .reduce((acc, w) => acc + w.cost, 0);

  const remainingBalance = totalIncome - (totalCommitted + totalSpent);
  const projectedSavings = remainingBalance - totalPlannedWishlist;

  return {
    totalIncome,
    totalFixed,
    totalInstallments,
    totalCreditCards,
    totalSubscriptions,
    totalCommitted,
    totalCash,
    totalCard,
    totalSpent,
    totalPlannedWishlist,
    remainingBalance,
    projectedSavings
  };
}

function calculateForecast() {
  const estimatedIncome = state.members.reduce((acc, m) => acc + m.salary, 0);
  const recurringFixed = state.fixedPayments.reduce((acc, f) => acc + f.amount, 0);
  const recurringSubs = state.subscriptions.reduce((acc, s) => acc + s.amountLkr, 0);
  const estimatedNextCC = 10000;

  let continuingInstallments = 0;
  let endingCount = 0;
  let continuingCount = 0;

  for (const plan of state.installments) {
    const balAfterCurrent = plan.remaining - plan.monthly;
    if (balAfterCurrent > 0.01) {
      continuingCount++;
      const nextDue = balAfterCurrent < plan.monthly ? balAfterCurrent : plan.monthly;
      continuingInstallments += nextDue;
    } else {
      endingCount++;
    }
  }

  const totalCommitted = recurringFixed + continuingInstallments + recurringSubs + estimatedNextCC;
  const netBalance = estimatedIncome - totalCommitted;
  const hasShortfall = netBalance < 0;
  const shortfallAmount = hasShortfall ? Math.abs(netBalance) : 0;

  // Tunable reserve percentage (default 5.0%)
  const reservePct = (state.forecastSettings && state.forecastSettings.reservePercentage) ? state.forecastSettings.reservePercentage : 5.0;
  const reserveMargin = (reservePct / 100.0) * estimatedIncome;
  const requiredBuffer = hasShortfall ? (shortfallAmount + reserveMargin) : 0;

  return {
    estimatedIncome,
    recurringFixed,
    continuingInstallments,
    recurringSubs,
    estimatedNextCC,
    totalCommitted,
    netBalance,
    hasShortfall,
    shortfallAmount,
    requiredBuffer,
    endingCount,
    continuingCount,
    reservePct
  };
}

function fmt(num) {
  const sym = state.household.currency || "Rs.";
  return `${sym} ` + Math.round(num).toLocaleString();
}

// --- RENDER APPLICATION & THEME ---

function applyTheme() {
  const theme = state.household.themePreset || "theme-emerald";
  document.body.className = theme;

  const appName = state.household.name || "HomeBudget";
  const appLogo = state.household.logo || "💰";

  document.getElementById("sidebar-app-name").textContent = appName;
  document.getElementById("app-logo-icon").textContent = appLogo;
  document.getElementById("html-head-title").textContent = `${appName} | 25th Cycle Tracker`;

  // Highlight active theme preset card in CMS
  document.querySelectorAll(".theme-card").forEach(c => {
    c.classList.toggle("active", c.getAttribute("data-theme") === theme);
  });
}

function renderApp() {
  persistState();
  applyTheme();

  const m = calculateMetrics();
  const f = calculateForecast();

  // User & Auth State
  const user = state.currentUser;
  document.getElementById("user-display-name").textContent = `${user.name} (${user.isAdmin ? "Admin" : "Member"})`;
  document.getElementById("user-display-email").textContent = user.email;
  document.getElementById("user-avatar-badge").textContent = (user.name || "A").charAt(0).toUpperCase();

  // Balance Header
  document.getElementById("remaining-balance-display").textContent = fmt(m.remainingBalance);
  document.getElementById("projected-savings-display").textContent = fmt(m.projectedSavings);
  document.getElementById("total-income-display").textContent = fmt(m.totalIncome);

  const forecastBadge = document.getElementById("forecast-badge");
  if (f.hasShortfall) {
    forecastBadge.className = "badge badge-danger";
    forecastBadge.textContent = `⚠️ Next Month Shortfall (${fmt(f.shortfallAmount)})`;
  } else {
    forecastBadge.className = "badge badge-success";
    forecastBadge.textContent = `✅ Next Month Surplus (${fmt(f.netBalance)})`;
  }

  // AI Guidance with Safe Fallback
  const aiCard = document.getElementById("ai-guidance-card");
  if (aiCard) {
    document.getElementById("ai-advice-text").innerHTML = generateGuidanceText(m, f);
  }

  // Metric Cards
  document.getElementById("metric-income").textContent = fmt(m.totalIncome);
  document.getElementById("metric-committed").textContent = fmt(m.totalCommitted);
  document.getElementById("metric-spent").textContent = fmt(m.totalSpent);
  document.getElementById("metric-spent-sub").textContent = `Cash: ${fmt(m.totalCash)} • Card: ${fmt(m.totalCard)}`;
  document.getElementById("metric-wishlist").textContent = fmt(m.totalPlannedWishlist);

  // Outgoings Breakdown
  document.getElementById("bk-fixed").textContent = fmt(m.totalFixed);
  document.getElementById("bk-installments").textContent = fmt(m.totalInstallments);
  document.getElementById("bk-cc").textContent = fmt(m.totalCreditCards);
  document.getElementById("bk-subs").textContent = fmt(m.totalSubscriptions);

  // Render all tabs
  renderRecentSpends();
  renderDailySpendsTab();
  renderInstallmentsTab();
  renderFixedBillsTab();
  renderWishlistTab();
  renderSubscriptionsTab();
  renderCreditCardsTab();
  renderForecastTab(f, m);
  renderAdminCmsTables();
}

function generateGuidanceText(m, f) {
  if (f.hasShortfall) {
    return `⚠️ <strong>Survival Warning:</strong> Next cycle shows a projected deficit of <strong>${fmt(f.shortfallAmount)}</strong>. Based on your <strong>${f.reservePct}% reserve margin</strong>, reserve at least <strong>${fmt(f.requiredBuffer)}</strong> from your current remaining balance (${fmt(m.remainingBalance)}) to guarantee you do not run short. Consider deferring wishlist items.`;
  } else {
    return `✅ <strong>Solid Financial Position:</strong> You have <strong>${fmt(m.remainingBalance)}</strong> remaining with 26 days to go. <strong>${f.endingCount} installment plans</strong> finish this cycle, freeing up cash flow. Next cycle is projected to have a healthy surplus of <strong>${fmt(f.netBalance)}</strong>.`;
  }
}

// --- RENDER MAIN USER SCREENS WITH FULL IN-PLACE CRUD ---

function renderRecentSpends() {
  const container = document.getElementById("dashboard-recent-spends");
  const recent = state.dailySpends.slice(0, 5);

  container.innerHTML = recent.map(s => `
    <div class="spend-item">
      <div class="item-left">
        <span class="item-icon">${s.method.toLowerCase().includes("cash") ? "💵" : "💳"}</span>
        <div>
          <div class="item-title">${s.title}</div>
          <div class="item-meta">${s.date} • ${s.cat} (${s.method})</div>
        </div>
      </div>
      <div class="item-right">
        <div class="item-amount danger">-${fmt(s.amount)}</div>
        <div class="item-actions">
          <button class="btn-item-edit" onclick="editSpendModal('${s.id}')">✏️ Edit</button>
          <button class="btn-item-delete" onclick="deleteSpend('${s.id}')">🗑️</button>
        </div>
      </div>
    </div>
  `).join("");
}

function renderDailySpendsTab() {
  const container = document.getElementById("daily-spends-container");
  container.innerHTML = state.dailySpends.map(s => `
    <div class="spend-item" style="margin-bottom: 8px;">
      <div class="item-left">
        <span class="item-icon">${s.method.toLowerCase().includes("cash") ? "💵" : "💳"}</span>
        <div>
          <div class="item-title">${s.title}</div>
          <div class="item-meta">${s.date} • ${s.cat} • <strong>${s.method}</strong></div>
        </div>
      </div>
      <div class="item-right">
        <div class="item-amount danger">-${fmt(s.amount)}</div>
        <div class="item-actions">
          <button class="btn-item-edit" onclick="editSpendModal('${s.id}')">✏️ Edit</button>
          <button class="btn-item-delete" onclick="deleteSpend('${s.id}')">🗑️ Delete</button>
        </div>
      </div>
    </div>
  `).join("");
}

function renderInstallmentsTab() {
  const container = document.getElementById("installments-container");
  container.innerHTML = state.installments.map(inst => {
    const pct = Math.min(100, Math.round(((inst.total - inst.remaining) / inst.total) * 100));
    const continues = (inst.remaining - inst.monthly) > 0.01;

    return `
      <div class="installment-card">
        <div class="installment-top">
          <span class="platform-tag">${inst.platform} • ${inst.member}</span>
          <div style="display: flex; gap: 6px;">
            <button class="btn btn-sm ${inst.isPaid ? 'btn-primary' : 'btn-secondary'}" onclick="toggleInstPaid('${inst.id}')">
              ${inst.isPaid ? '✓ Paid This Month' : 'Mark Paid'}
            </button>
            <button class="btn-item-edit" onclick="openBnplModal(state.installments.find(x => x.id === '${inst.id}'))">✏️</button>
            <button class="btn-item-delete" onclick="deleteBnpl('${inst.id}')">🗑️</button>
          </div>
        </div>
        <div class="item-title" style="font-size: 15px;">${inst.item}</div>
        <div class="progress-bar-bg">
          <div class="progress-bar-fill" style="width: ${pct}%;"></div>
        </div>
        <div style="display: flex; justify-content: space-between; font-size: 13px;">
          <span>Monthly: <strong>${fmt(inst.monthly)}</strong></span>
          <span class="text-muted">Balance: ${fmt(inst.remaining)}</span>
        </div>
        <div style="font-size: 11px; margin-top: 6px; color: ${continues ? 'var(--warning)' : 'var(--primary-light)'};">
          ${continues ? '➔ Continues to next month' : '🎉 Finishes this month!'}
        </div>
      </div>
    `;
  }).join("");
}

function renderFixedBillsTab() {
  const container = document.getElementById("fixed-bills-container");
  container.innerHTML = state.fixedPayments.map(b => `
    <div class="bill-item">
      <div class="item-left">
        <button class="btn-icon" onclick="toggleBillPaid('${b.id}')">
          ${b.isPaid ? '✅' : '⭕'}
        </button>
        <div>
          <div class="item-title" style="${b.isPaid ? 'text-decoration: line-through; opacity: 0.6;' : ''}">${b.name}</div>
          <div class="item-meta">Due: ${b.dueDay}th • ${b.category} (${b.dest || 'Bank Account'})</div>
        </div>
      </div>
      <div class="item-right">
        <div class="item-amount">${fmt(b.amount)}</div>
        <div class="item-actions">
          <button class="btn-item-edit" onclick="openBillModal(state.fixedPayments.find(x => x.id === '${b.id}'))">✏️ Edit</button>
          <button class="btn-item-delete" onclick="deleteBill('${b.id}')">🗑️</button>
        </div>
      </div>
    </div>
  `).join("");
}

function renderWishlistTab() {
  const container = document.getElementById("wishlist-container");
  container.innerHTML = state.wishlist.map(w => `
    <div class="bill-item" style="margin-bottom: 8px;">
      <div class="item-left">
        <input type="checkbox" ${w.isPlanned ? 'checked' : ''} onchange="toggleWishlistPlan('${w.id}')" style="width: 18px; height: 18px; cursor: pointer;">
        <div>
          <div class="item-title">${w.item}</div>
          <div class="item-meta">${w.category} • Priority: <strong>${w.priority.toUpperCase()}</strong> • ${w.isPlanned ? '<span style="color: var(--primary-light)">Planned this cycle</span>' : 'Not planned'}</div>
        </div>
      </div>
      <div class="item-right">
        <div class="item-amount">${fmt(w.cost)}</div>
        <div class="item-actions">
          <button class="btn-item-edit" onclick="openWishlistModal(state.wishlist.find(x => x.id === '${w.id}'))">✏️ Edit</button>
          <button class="btn-item-delete" onclick="deleteWishlistItem('${w.id}')">🗑️</button>
        </div>
      </div>
    </div>
  `).join("");
}

function renderSubscriptionsTab() {
  const container = document.getElementById("subscriptions-container");
  container.innerHTML = state.subscriptions.map(s => `
    <div class="bill-item" style="margin-bottom: 8px;">
      <div class="item-left">
        <button class="btn-icon" onclick="toggleSubPaid('${s.id}')">
          ${s.isPaid ? '✅' : '⭕'}
        </button>
        <div>
          <div class="item-title" style="${s.isPaid ? 'text-decoration: line-through; opacity: 0.6;' : ''}">${s.name}</div>
          <div class="item-meta">Billing: ${s.billingDay}th of month</div>
        </div>
      </div>
      <div class="item-right">
        <div class="item-amount">${fmt(s.amountLkr)}</div>
        <div class="item-actions">
          <button class="btn-item-edit" onclick="openSubModal(state.subscriptions.find(x => x.id === '${s.id}'))">✏️ Edit</button>
          <button class="btn-item-delete" onclick="deleteSub('${s.id}')">🗑️</button>
        </div>
      </div>
    </div>
  `).join("");
}

function renderCreditCardsTab() {
  const container = document.getElementById("credit-cards-container");
  if (!container) return;
  container.innerHTML = state.creditCards.map(c => `
    <div class="bill-item" style="margin-bottom: 8px;">
      <div class="item-left">
        <span class="item-icon">💳</span>
        <div>
          <div class="item-title">${c.name}</div>
          <div class="item-meta">${c.bank}</div>
        </div>
      </div>
      <div class="item-right">
        <div class="item-amount">${fmt(c.due)}</div>
        <div class="item-actions">
          <button class="btn-item-edit" onclick="openCardModal(state.creditCards.find(x => x.id === '${c.id}'))">✏️ Edit</button>
          <button class="btn-item-delete" onclick="deleteCard('${c.id}')">🗑️</button>
        </div>
      </div>
    </div>
  `).join("");
}

function renderForecastTab(f, m) {
  const heroBox = document.getElementById("forecast-hero-box");
  const verdictTitle = document.getElementById("forecast-verdict-title");
  const verdictDesc = document.getElementById("forecast-verdict-desc");

  if (f.hasShortfall) {
    heroBox.className = "forecast-hero shortfall";
    verdictTitle.textContent = `Shortfall Alert: -${fmt(f.shortfallAmount)}`;
    verdictDesc.textContent = `Next month will be short by ${fmt(f.shortfallAmount)}. Mandatory Action: Reserve at least ${fmt(f.requiredBuffer)} (including ${f.reservePct}% reserve) from this month's balance to avoid debt.`;
  } else {
    heroBox.className = "forecast-hero";
    verdictTitle.textContent = `Next Cycle Surplus: +${fmt(f.netBalance)}`;
    verdictDesc.textContent = `Your regular salaries comfortably cover recurring bills and continuing BNPL installments. Safe spendable buffer available.`;
  }

  document.getElementById("fc-income").textContent = fmt(f.estimatedIncome);
  document.getElementById("fc-committed").textContent = fmt(f.totalCommitted);
  document.getElementById("fc-ending").textContent = `${f.endingCount} Plans Ending 🎉`;
  document.getElementById("fc-buffer").textContent = f.hasShortfall ? fmt(f.requiredBuffer) : "Rs. 0 (Safe)";
  document.getElementById("fc-buffer-sub").textContent = `Based on ${f.reservePct}% safety reserve`;

  const detailsList = document.getElementById("forecast-details-list");
  detailsList.innerHTML = `
    <div class="breakdown-item"><span class="dot green"></span><span>Estimated Next Salaries (Husband + Wife)</span><strong>+${fmt(f.estimatedIncome)}</strong></div>
    <div class="breakdown-item"><span class="dot red"></span><span>Recurring Fixed Bills (Rent, ECB, Loan)</span><strong>-${fmt(f.recurringFixed)}</strong></div>
    <div class="breakdown-item"><span class="dot amber"></span><span>Continuing BNPL Installments (${f.continuingCount} active)</span><strong>-${fmt(f.continuingInstallments)}</strong></div>
    <div class="breakdown-item"><span class="dot purple"></span><span>Active Subscriptions (Dialog, Netflix, Apple)</span><strong>-${fmt(f.recurringSubs)}</strong></div>
    <div class="breakdown-item"><span class="dot blue"></span><span>Estimated Credit Card Base</span><strong>-${fmt(f.estimatedNextCC)}</strong></div>
    <div class="breakdown-item" style="border-top: 1px solid var(--border-color); padding-top: 10px;">
      <span><strong>Projected Net Balance</strong></span>
      <strong style="color: ${f.hasShortfall ? 'var(--danger)' : 'var(--primary-light)'}; font-size: 16px;">
        ${f.hasShortfall ? '-' : '+'}${fmt(f.hasShortfall ? f.shortfallAmount : f.netBalance)}
      </strong>
    </div>
  `;
}

// --- ADMIN CMS RENDER & THEME SWITCHER ---

function selectThemePreset(themeClass) {
  state.household.themePreset = themeClass;
  renderApp();
}

function saveThemeSettings() {
  state.household.name = document.getElementById("cms-app-name-input").value.trim() || "HomeBudget";
  state.household.logo = document.getElementById("cms-app-logo-input").value.trim() || "💰";
  alert("Theme and branding updated successfully!");
  renderApp();
}

function saveUiLabels() {
  state.uiLabels.lbl_dashboard_title = document.getElementById("lbl-input-dashboard").value.trim();
  state.uiLabels.lbl_balance_header = document.getElementById("lbl-input-balance").value.trim();
  state.household.currency = document.getElementById("lbl-input-currency").value.trim() || "Rs.";
  alert("UI labels saved!");
  renderApp();
}

function saveForecastSettings() {
  const pct = parseFloat(document.getElementById("fc-reserve-pct-input").value) || 5.0;
  const days = parseInt(document.getElementById("fc-buffer-days-input").value) || 30;
  state.forecastSettings.reservePercentage = pct;
  state.forecastSettings.survivalBufferDays = days;
  alert("Forecast parameters updated! Survival buffer re-calculated.");
  renderApp();
}

function renderAdminCmsTables() {
  // Members Table
  const membersBody = document.getElementById("cms-members-table-body");
  if (membersBody) {
    membersBody.innerHTML = state.members.map(m => `
      <tr>
        <td><strong>${m.name}</strong></td>
        <td><span class="platform-tag">${m.role}</span></td>
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

  // System & Keys Inputs
  if (document.getElementById("cms-cycle-day")) {
    document.getElementById("cms-cycle-day").value = state.household.cycleStartDay;
    document.getElementById("cms-gemini-key").value = state.household.geminiApiKey || "";
  }
}

// --- CMS EDIT/ADD MODAL UTILS ---
const cmsModal = document.getElementById("cms-modal");
let cmsSaveCallback = null;

function openCmsModal(title, formHtml, onSave) {
  document.getElementById("cms-modal-title").textContent = title;
  document.getElementById("cms-modal-body").innerHTML = formHtml;
  cmsSaveCallback = onSave;
  cmsModal.classList.add("active");
}

function closeCmsModal() {
  cmsModal.classList.remove("active");
  cmsSaveCallback = null;
}

document.getElementById("cms-modal-save-btn").addEventListener("click", () => {
  if (cmsSaveCallback) cmsSaveCallback();
});

// --- MEMBER CRUD ---
function openMemberModal(member = null) {
  const isEdit = member !== null;
  const html = `
    <div class="form-group">
      <label>Name</label>
      <input type="text" id="m-name" class="form-control" value="${isEdit ? member.name : ''}">
    </div>
    <div class="form-group">
      <label>Role</label>
      <input type="text" id="m-role" class="form-control" value="${isEdit ? member.role : 'husband'}">
    </div>
    <div class="form-group">
      <label>Regular Monthly Salary (Rs.)</label>
      <input type="number" id="m-salary" class="form-control" value="${isEdit ? member.salary : '200000'}">
    </div>
  `;

  openCmsModal(isEdit ? "Edit Member" : "Add Member", html, () => {
    const name = document.getElementById("m-name").value.trim();
    const role = document.getElementById("m-role").value.trim();
    const salary = parseFloat(document.getElementById("m-salary").value) || 0;

    if (!name) return alert("Please enter a name.");

    if (isEdit) {
      member.name = name; member.role = role; member.salary = salary;
    } else {
      state.members.push({ id: "m_" + Date.now(), name, role, salary, color: "#10B981" });
    }
    closeCmsModal();
    renderApp();
  });
}

function deleteMember(id) {
  if (confirm("Delete this household member?")) {
    state.members = state.members.filter(x => x.id !== id);
    renderApp();
  }
}

// --- FIXED BILL CRUD ---
function openBillModal(bill = null) {
  const isEdit = bill !== null;
  const html = `
    <div class="form-group">
      <label>Bill Name</label>
      <input type="text" id="b-name" class="form-control" value="${isEdit ? bill.name : ''}">
    </div>
    <div class="form-group">
      <label>Amount (Rs.)</label>
      <input type="number" id="b-amount" class="form-control" value="${isEdit ? bill.amount : '50000'}">
    </div>
    <div class="form-group">
      <label>Category</label>
      <input type="text" id="b-cat" class="form-control" value="${isEdit ? bill.category : 'Housing'}">
    </div>
    <div class="form-group">
      <label>Due Day of Month</label>
      <input type="number" id="b-due" class="form-control" value="${isEdit ? bill.dueDay : '25'}">
    </div>
    <div class="form-group">
      <label>Destination Account / Bank</label>
      <input type="text" id="b-dest" class="form-control" value="${isEdit ? (bill.dest || '') : 'BOC Account'}">
    </div>
  `;

  openCmsModal(isEdit ? "Edit Fixed Bill" : "Add Fixed Bill", html, () => {
    const name = document.getElementById("b-name").value.trim();
    const amount = parseFloat(document.getElementById("b-amount").value) || 0;
    const category = document.getElementById("b-cat").value.trim();
    const dueDay = parseInt(document.getElementById("b-due").value) || 25;
    const dest = document.getElementById("b-dest").value.trim();

    if (!name || amount <= 0) return alert("Please fill valid bill name and amount.");

    if (isEdit) {
      bill.name = name; bill.amount = amount; bill.category = category; bill.dueDay = dueDay; bill.dest = dest;
    } else {
      state.fixedPayments.push({ id: "f_" + Date.now(), name, amount, category, dueDay, dest, isPaid: false });
    }
    closeCmsModal();
    renderApp();
  });
}

function deleteBill(id) {
  if (confirm("Delete this bill?")) {
    state.fixedPayments = state.fixedPayments.filter(x => x.id !== id);
    renderApp();
  }
}

// --- BNPL CRUD ---
function openBnplModal(inst = null) {
  const isEdit = inst !== null;
  const html = `
    <div class="form-group">
      <label>Item Name</label>
      <input type="text" id="i-name" class="form-control" value="${isEdit ? inst.item : ''}">
    </div>
    <div class="form-group">
      <label>Platform (Koko, Mintpay, PayZy)</label>
      <input type="text" id="i-plat" class="form-control" value="${isEdit ? inst.platform : 'Koko'}">
    </div>
    <div class="form-group">
      <label>Assigned Member</label>
      <input type="text" id="i-mem" class="form-control" value="${isEdit ? inst.member : 'Dhiyan'}">
    </div>
    <div class="form-group">
      <label>Monthly Installment (Rs.)</label>
      <input type="number" id="i-month" class="form-control" value="${isEdit ? inst.monthly : '4500'}">
    </div>
    <div class="form-group">
      <label>Remaining Balance (Rs.)</label>
      <input type="number" id="i-rem" class="form-control" value="${isEdit ? inst.remaining : '9000'}">
    </div>
    <div class="form-group">
      <label>Total Cost (Rs.)</label>
      <input type="number" id="i-tot" class="form-control" value="${isEdit ? inst.total : '13500'}">
    </div>
  `;

  openCmsModal(isEdit ? "Edit BNPL Plan" : "Add BNPL Plan", html, () => {
    const item = document.getElementById("i-name").value.trim();
    const platform = document.getElementById("i-plat").value.trim();
    const member = document.getElementById("i-mem").value.trim();
    const monthly = parseFloat(document.getElementById("i-month").value) || 0;
    const remaining = parseFloat(document.getElementById("i-rem").value) || 0;
    const total = parseFloat(document.getElementById("i-tot").value) || monthly * 3;

    if (!item || monthly <= 0) return alert("Please fill valid item name and monthly amount.");

    if (isEdit) {
      inst.item = item; inst.platform = platform; inst.member = member; inst.monthly = monthly; inst.remaining = remaining; inst.total = total;
    } else {
      state.installments.push({ id: "inst_" + Date.now(), item, platform, member, monthly, remaining, total, isPaid: false });
    }
    closeCmsModal();
    renderApp();
  });
}

function deleteBnpl(id) {
  if (confirm("Delete this BNPL plan?")) {
    state.installments = state.installments.filter(x => x.id !== id);
    renderApp();
  }
}

// --- SUBSCRIPTIONS & CARDS CRUD ---
function openSubModal(sub = null) {
  const isEdit = sub !== null;
  const html = `
    <div class="form-group">
      <label>Subscription Name</label>
      <input type="text" id="s-name" class="form-control" value="${isEdit ? sub.name : ''}">
    </div>
    <div class="form-group">
      <label>Monthly LKR Amount</label>
      <input type="number" id="s-amt" class="form-control" value="${isEdit ? sub.amountLkr : '2500'}">
    </div>
    <div class="form-group">
      <label>Billing Day</label>
      <input type="number" id="s-day" class="form-control" value="${isEdit ? sub.billingDay : '24'}">
    </div>
  `;

  openCmsModal(isEdit ? "Edit Subscription" : "Add Subscription", html, () => {
    const name = document.getElementById("s-name").value.trim();
    const amountLkr = parseFloat(document.getElementById("s-amt").value) || 0;
    const billingDay = parseInt(document.getElementById("s-day").value) || 24;

    if (!name || amountLkr <= 0) return alert("Please fill valid subscription details.");

    if (isEdit) {
      sub.name = name; sub.amountLkr = amountLkr; sub.billingDay = billingDay;
    } else {
      state.subscriptions.push({ id: "s_" + Date.now(), name, amountLkr, billingDay, isPaid: false });
    }
    closeCmsModal();
    renderApp();
  });
}

function deleteSub(id) {
  if (confirm("Delete this subscription?")) {
    state.subscriptions = state.subscriptions.filter(x => x.id !== id);
    renderApp();
  }
}

function openCardModal(card = null) {
  const isEdit = card !== null;
  const html = `
    <div class="form-group">
      <label>Card Name</label>
      <input type="text" id="c-name" class="form-control" value="${isEdit ? card.name : 'Combank Platinum'}">
    </div>
    <div class="form-group">
      <label>Bank Name</label>
      <input type="text" id="c-bank" class="form-control" value="${isEdit ? card.bank : 'Commercial Bank'}">
    </div>
    <div class="form-group">
      <label>Statement Due Amount (Rs.)</label>
      <input type="number" id="c-due" class="form-control" value="${isEdit ? card.due : '40000'}">
    </div>
  `;

  openCmsModal(isEdit ? "Edit Credit Card" : "Add Credit Card", html, () => {
    const name = document.getElementById("c-name").value.trim();
    const bank = document.getElementById("c-bank").value.trim();
    const due = parseFloat(document.getElementById("c-due").value) || 0;

    if (!name) return alert("Please enter card name.");

    if (isEdit) {
      card.name = name; card.bank = bank; card.due = due;
    } else {
      state.creditCards.push({ id: "cc_" + Date.now(), name, bank, due, isPaid: false });
    }
    closeCmsModal();
    renderApp();
  });
}

function deleteCard(id) {
  if (confirm("Delete this card?")) {
    state.creditCards = state.creditCards.filter(x => x.id !== id);
    renderApp();
  }
}

// --- WISHLIST CRUD ---
function openWishlistModal(item = null) {
  const isEdit = item !== null;
  const html = `
    <div class="form-group">
      <label>Item Name</label>
      <input type="text" id="w-item" class="form-control" value="${isEdit ? item.item : ''}">
    </div>
    <div class="form-group">
      <label>Category</label>
      <input type="text" id="w-cat" class="form-control" value="${isEdit ? item.category : 'Kitchen'}">
    </div>
    <div class="form-group">
      <label>Estimated Cost (Rs.)</label>
      <input type="number" id="w-cost" class="form-control" value="${isEdit ? item.cost : '2000'}">
    </div>
    <div class="form-group">
      <label>Priority (high / medium / low)</label>
      <input type="text" id="w-pri" class="form-control" value="${isEdit ? item.priority : 'medium'}">
    </div>
  `;

  openCmsModal(isEdit ? "Edit Wishlist Item" : "Add Wishlist Item", html, () => {
    const itemName = document.getElementById("w-item").value.trim();
    const category = document.getElementById("w-cat").value.trim();
    const cost = parseFloat(document.getElementById("w-cost").value) || 0;
    const priority = document.getElementById("w-pri").value.trim().toLowerCase();

    if (!itemName) return alert("Please enter item name.");

    if (isEdit) {
      item.item = itemName; item.category = category; item.cost = cost; item.priority = priority;
    } else {
      state.wishlist.push({ id: "w_" + Date.now(), item: itemName, category, cost, priority, isPlanned: false });
    }
    closeCmsModal();
    renderApp();
  });
}

function deleteWishlistItem(id) {
  if (confirm("Delete this wishlist item?")) {
    state.wishlist = state.wishlist.filter(x => x.id !== id);
    renderApp();
  }
}

// --- SPENDS CRUD ---
function editSpendModal(id) {
  const s = state.dailySpends.find(x => x.id === id);
  if (!s) return;

  const html = `
    <div class="form-group">
      <label>Description</label>
      <input type="text" id="sp-title" class="form-control" value="${s.title}">
    </div>
    <div class="form-group">
      <label>Amount (Rs.)</label>
      <input type="number" id="sp-amt" class="form-control" value="${s.amount}">
    </div>
    <div class="form-group">
      <label>Category</label>
      <input type="text" id="sp-cat" class="form-control" value="${s.cat}">
    </div>
    <div class="form-group">
      <label>Payment Method</label>
      <input type="text" id="sp-method" class="form-control" value="${s.method}">
    </div>
  `;

  openCmsModal("Edit Daily Spend", html, () => {
    const title = document.getElementById("sp-title").value.trim();
    const amount = parseFloat(document.getElementById("sp-amt").value) || 0;
    const cat = document.getElementById("sp-cat").value.trim();
    const method = document.getElementById("sp-method").value.trim();

    if (!title || amount <= 0) return alert("Please fill valid details.");

    s.title = title; s.amount = amount; s.cat = cat; s.method = method;
    closeCmsModal();
    renderApp();
  });
}

function deleteSpend(id) {
  if (confirm("Delete this spend entry?")) {
    state.dailySpends = state.dailySpends.filter(s => s.id !== id);
    renderApp();
  }
}

// --- SYSTEM CONFIG & BACKUP ---
function saveCmsSystemSettings() {
  state.household.cycleStartDay = parseInt(document.getElementById("cms-cycle-day").value) || 25;
  state.household.geminiApiKey = document.getElementById("cms-gemini-key").value.trim();
  alert("System parameters saved!");
  renderApp();
}

function exportDatabaseJson() {
  const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(state, null, 2));
  const downloadAnchor = document.createElement('a');
  downloadAnchor.setAttribute("href", dataStr);
  downloadAnchor.setAttribute("download", `homebudget_backup_${new Date().toISOString().split('T')[0]}.json`);
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  downloadAnchor.remove();
}

function importDatabaseJson(event) {
  const file = event.target.files[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = function(e) {
    try {
      const imported = JSON.parse(e.target.result);
      if (imported.household && imported.members) {
        state = imported;
        alert("Database restored successfully!");
        renderApp();
      } else {
        alert("Invalid backup JSON format.");
      }
    } catch (err) {
      alert("Error reading JSON file.");
    }
  };
  reader.readAsText(file);
}

function resetToSampleData() {
  if (confirm("Reset everything back to handwritten notebook sample data?")) {
    state = JSON.parse(JSON.stringify(defaultState));
    localStorage.removeItem(STORAGE_KEY);
    renderApp();
  }
}

// --- AUTH CONTROLLER & FIRST-RUN SETUP ---
const authModal = document.getElementById("auth-modal");

function openAuthModal() {
  const isFirstRun = !state.adminSetup.hasAdminRegistered;
  document.getElementById("auth-first-run-banner").style.display = isFirstRun ? "block" : "none";
  document.getElementById("auth-name-group").style.display = isFirstRun ? "block" : "none";
  document.getElementById("auth-submit-btn").textContent = isFirstRun ? "Register Household Admin" : "Log In";
  document.getElementById("auth-modal-title").textContent = isFirstRun ? "👑 First-Run Admin Setup" : "🔐 Household Access";
  authModal.classList.add("active");
}

function closeAuthModal() {
  authModal.classList.remove("active");
}

function quickLoginDemo() {
  state.currentUser = {
    name: "Sathsara",
    email: "admin@homebudget.lk",
    role: "husband",
    isAdmin: true
  };
  closeAuthModal();
  renderApp();
}

function handleAuthSubmit() {
  const email = document.getElementById("auth-email-input").value.trim();
  const password = document.getElementById("auth-password-input").value.trim();

  if (!email || !password) return alert("Please enter email and password.");

  if (!state.adminSetup.hasAdminRegistered) {
    const name = document.getElementById("auth-name-input").value.trim() || "Admin";
    state.adminSetup.hasAdminRegistered = true;
    state.adminSetup.adminEmail = email;
    state.currentUser = { name, email, role: "husband", isAdmin: true };
    alert(`Admin account created! Registration is now permanently locked to ${email}.`);
  } else {
    state.currentUser = {
      name: email.includes("wife") || email.includes("dhiyan") ? "Dhiyan" : "Sathsara",
      email: email,
      role: email.includes("wife") ? "wife" : "husband",
      isAdmin: email === state.adminSetup.adminEmail || email.includes("admin")
    };
  }

  closeAuthModal();
  renderApp();
}

document.getElementById("btn-auth-action").addEventListener("click", openAuthModal);
document.getElementById("auth-modal-close").addEventListener("click", closeAuthModal);
document.getElementById("auth-modal-cancel").addEventListener("click", closeAuthModal);

// --- NAVIGATION & EVENT LISTENERS ---
function toggleBillPaid(id) {
  const bill = state.fixedPayments.find(b => b.id === id);
  if (bill) { bill.isPaid = !bill.isPaid; renderApp(); }
}

function toggleInstPaid(id) {
  const inst = state.installments.find(i => i.id === id);
  if (inst) { inst.isPaid = !inst.isPaid; renderApp(); }
}

function toggleSubPaid(id) {
  const sub = state.subscriptions.find(s => s.id === id);
  if (sub) { sub.isPaid = !sub.isPaid; renderApp(); }
}

function toggleWishlistPlan(id) {
  const item = state.wishlist.find(w => w.id === id);
  if (item) { item.isPlanned = !item.isPlanned; renderApp(); }
}

function switchTab(tabId) {
  document.querySelectorAll(".tab-pane").forEach(el => el.classList.remove("active"));
  document.querySelectorAll(".nav-item").forEach(el => el.classList.remove("active"));

  const targetPane = document.getElementById("tab-" + tabId);
  const targetNav = document.querySelector(`[data-tab="${tabId}"]`);

  if (targetPane) targetPane.classList.add("active");
  if (targetNav) targetNav.classList.add("active");

  const titles = {
    "dashboard": "Cycle Overview",
    "daily-spends": "Daily Spend Tracker",
    "installments": "BNPL & Koko Installments",
    "fixed-bills": "Fixed Bills & Loans",
    "forecast": "Forward Survival Forecast",
    "wishlist": "Wishlist & Things to Buy",
    "subscriptions": "Subscriptions & Auto-Pay",
    "admin-cms": "Scoped Admin CMS Control Panel"
  };
  document.getElementById("page-title").textContent = titles[tabId] || "Household Budget";
}

document.querySelectorAll(".nav-item").forEach(btn => {
  btn.addEventListener("click", () => switchTab(btn.getAttribute("data-tab")));
});

document.querySelectorAll(".cms-nav-btn").forEach(btn => {
  btn.addEventListener("click", () => {
    document.querySelectorAll(".cms-nav-btn").forEach(b => b.classList.remove("active"));
    document.querySelectorAll(".cms-view-pane").forEach(p => p.classList.remove("active"));
    btn.classList.add("active");
    const target = btn.getAttribute("data-cms-view");
    const pane = document.getElementById(target);
    if (pane) pane.classList.add("active");
  });
});

document.getElementById("btn-open-cms").addEventListener("click", () => switchTab("admin-cms"));
document.getElementById("btn-forecast-modal").addEventListener("click", () => switchTab("forecast"));

// Spend Dialog
const spendModal = document.getElementById("spend-modal");
let currentSpendMethod = "Cash";
let currentSpendCat = "Groceries";

function openSpendModal() {
  spendModal.classList.add("active");
  document.getElementById("spend-amount-input").value = "";
  document.getElementById("spend-title-input").value = "";
  document.getElementById("spend-amount-input").focus();
}

function closeSpendModal() {
  spendModal.classList.remove("active");
}

document.getElementById("btn-quick-spend").addEventListener("click", openSpendModal);
document.getElementById("btn-add-spend-page").addEventListener("click", openSpendModal);
document.getElementById("modal-close-btn").addEventListener("click", closeSpendModal);
document.getElementById("modal-cancel-btn").addEventListener("click", closeSpendModal);

document.querySelectorAll("#payment-method-chips .chip").forEach(c => {
  c.addEventListener("click", () => {
    document.querySelectorAll("#payment-method-chips .chip").forEach(x => x.classList.remove("active"));
    c.classList.add("active");
    currentSpendMethod = c.getAttribute("data-method");
  });
});

document.querySelectorAll("#category-chips .chip").forEach(c => {
  c.addEventListener("click", () => {
    document.querySelectorAll("#category-chips .chip").forEach(x => x.classList.remove("active"));
    c.classList.add("active");
    currentSpendCat = c.getAttribute("data-cat");
  });
});

document.getElementById("modal-save-spend-btn").addEventListener("click", () => {
  const amount = parseFloat(document.getElementById("spend-amount-input").value);
  const title = document.getElementById("spend-title-input").value.trim();

  if (!amount || amount <= 0 || !title) {
    alert("Please enter a valid amount and description.");
    return;
  }

  const now = new Date();
  const dateStr = now.toISOString().split("T")[0];

  state.dailySpends.unshift({
    id: "d_" + Date.now(),
    date: dateStr,
    amount: amount,
    cat: currentSpendCat,
    method: currentSpendMethod,
    title: title
  });

  closeSpendModal();
  renderApp();
});

// Initial Render
renderApp();
