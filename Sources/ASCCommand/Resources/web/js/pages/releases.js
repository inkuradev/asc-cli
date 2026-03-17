import { asc, toList } from '../api.js';
import { state } from '../state.js';
import { esc, badge, affordanceButtons, primaryButton, secondaryButton, linkButton, editableField, detailRow, loading, empty, toast } from '../components.js';

// Track which version is expanded
let expandedVersionId = null;
let versionDetail = null;  // localizations, review detail, etc.

export async function render() {
  if (!state.appId) return empty('No app connected', 'Select an app from the dropdown above.');

  const versions = toList(await asc(`versions list --app-id ${state.appId} --output json`));
  if (!versions.length) return empty('No versions', 'Create your first version to get started.');

  const active = versions.filter(v => ['PREPARE_FOR_SUBMISSION', 'WAITING_FOR_REVIEW', 'IN_REVIEW', 'PENDING_DEVELOPER_RELEASE', 'PROCESSING_FOR_APP_STORE'].includes(v.state));
  const live = versions.filter(v => v.state === 'READY_FOR_SALE');
  const past = versions.filter(v => !active.includes(v) && !live.includes(v));

  let html = `<div class="flex items-center justify-between mb-6">
    <h1 class="text-lg font-semibold text-neutral-900">Releases</h1>
    ${primaryButton('+ New Version', `asc versions create --app-id ${state.appId} --platform ${state.platform} --version-string `)}
  </div>`;

  if (active.length) {
    html += active.map(v => versionCard(v)).join('');
  }

  if (live.length) {
    html += `<div class="mt-8 mb-3"><span class="text-[0.65rem] font-semibold text-neutral-400 uppercase tracking-wider">Live</span></div>`;
    html += live.map(v => versionCard(v)).join('');
  }

  if (past.length) {
    html += `<div class="mt-8 mb-3"><span class="text-[0.65rem] font-semibold text-neutral-400 uppercase tracking-wider">Previous</span></div>`;
    html += past.slice(0, 5).map(v => versionCard(v)).join('');
  }

  // If a version is expanded, load its detail after render
  if (expandedVersionId) {
    setTimeout(() => loadVersionDetail(expandedVersionId), 0);
  }

  return html;
}

function versionCard(v) {
  const a = v.affordances || {};
  const isExpanded = expandedVersionId === v.id;

  return `
    <div class="bg-white border border-neutral-200 rounded-xl mb-3 overflow-hidden hover:shadow-sm transition-shadow">
      <!-- Header: click to expand -->
      <div class="flex items-center justify-between px-5 py-3.5 cursor-pointer version-header" data-version-id="${esc(v.id)}">
        <div class="flex items-center gap-3">
          <svg class="w-3.5 h-3.5 text-neutral-400 transition-transform ${isExpanded ? 'rotate-90' : ''}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>
          <span class="text-base font-semibold text-neutral-900 tabular-nums">${esc(v.versionString || v.version || '?')}</span>
          ${badge(v.state)}
          ${v.platform ? `<span class="text-[0.6rem] font-mono text-neutral-400">${esc(v.platform)}</span>` : ''}
        </div>
        <div class="flex items-center gap-2" onclick="event.stopPropagation()">
          ${a.submitForReview ? primaryButton('Submit for Review', a.submitForReview) : ''}
          ${a.checkReadiness ? secondaryButton('Check Readiness', a.checkReadiness) : ''}
        </div>
      </div>

      <!-- Expanded detail panel -->
      <div id="version-detail-${esc(v.id)}" class="${isExpanded ? '' : 'hidden'} border-t border-neutral-100">
        <div class="px-5 py-4">
          <!-- Summary row -->
          <div class="grid grid-cols-3 gap-4 mb-4">
            <div class="bg-neutral-50 rounded-lg px-3.5 py-2.5">
              <p class="text-[0.6rem] text-neutral-400 uppercase tracking-wider mb-1">Build</p>
              <p class="text-sm font-medium text-neutral-800">${v.buildId ? `#${esc(v.buildId).slice(-6)}` : '<span class="text-neutral-400">Not attached</span>'}</p>
            </div>
            <div class="bg-neutral-50 rounded-lg px-3.5 py-2.5">
              <p class="text-[0.6rem] text-neutral-400 uppercase tracking-wider mb-1">Version ID</p>
              <p class="text-xs font-mono text-neutral-500 truncate" title="${esc(v.id)}">${esc(v.id)}</p>
            </div>
            <div class="bg-neutral-50 rounded-lg px-3.5 py-2.5">
              <p class="text-[0.6rem] text-neutral-400 uppercase tracking-wider mb-1">App</p>
              <p class="text-xs font-mono text-neutral-500 truncate">${esc(v.appId)}</p>
            </div>
          </div>

          <!-- Tabs: Localizations | Review Detail | Actions -->
          <div class="flex gap-4 border-b border-neutral-100 mb-4">
            <button class="version-tab text-xs font-medium pb-2 border-b-2 border-blue-600 text-blue-600 cursor-pointer" data-tab="localizations" data-version-id="${esc(v.id)}">Localizations</button>
            <button class="version-tab text-xs font-medium pb-2 border-b-2 border-transparent text-neutral-400 hover:text-neutral-600 cursor-pointer" data-tab="review" data-version-id="${esc(v.id)}">Review Detail</button>
            <button class="version-tab text-xs font-medium pb-2 border-b-2 border-transparent text-neutral-400 hover:text-neutral-600 cursor-pointer" data-tab="actions" data-version-id="${esc(v.id)}">Actions</button>
          </div>

          <!-- Tab content (loaded dynamically) -->
          <div id="version-tab-content-${esc(v.id)}">
            ${isExpanded ? '<div class="text-xs text-neutral-400">Loading...</div>' : ''}
          </div>
        </div>
      </div>
    </div>`;
}

// ── Dynamic detail loading ────────────────────────────
async function loadVersionDetail(versionId) {
  const container = document.getElementById(`version-tab-content-${versionId}`);
  if (!container) return;

  container.innerHTML = '<div class="flex items-center gap-2 text-neutral-400 text-xs py-4"><svg class="w-3.5 h-3.5 animate-spin" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3" opacity="0.2"/><path d="M12 2a10 10 0 019.95 9" stroke="currentColor" stroke-width="3" stroke-linecap="round"/></svg> Loading localizations...</div>';

  try {
    const locs = toList(await asc(`version-localizations list --version-id ${versionId} --output json`));
    container.innerHTML = renderLocalizationsTab(locs, versionId);
  } catch (err) {
    container.innerHTML = `<p class="text-xs text-red-500">${esc(err.message)}</p>`;
  }
}

function renderLocalizationsTab(locs, versionId) {
  if (!locs.length) return '<p class="text-xs text-neutral-400 py-2">No localizations found.</p>';

  return locs.map(loc => {
    const updateCmd = loc.affordances?.updateLocalization || `asc version-localizations update --localization-id ${loc.id}`;

    return `
      <div class="mb-4 pb-4 border-b border-neutral-50 last:border-0">
        <div class="flex items-center gap-2 mb-3">
          <span class="text-xs font-semibold text-neutral-700">${esc(loc.locale)}</span>
          ${loc.affordances?.listScreenshotSets ? linkButton('Screenshots', loc.affordances.listScreenshotSets) : ''}
        </div>
        <div class="grid grid-cols-1 gap-3">
          ${editableField('What\'s New', loc.whatsNew, updateCmd, '--whats-new', { multiline: true })}
          ${editableField('Description', loc.description, updateCmd, '--description', { multiline: true })}
          ${editableField('Keywords', loc.keywords, updateCmd, '--keywords')}
        </div>
      </div>`;
  }).join('');
}

async function loadReviewDetailTab(versionId) {
  const container = document.getElementById(`version-tab-content-${versionId}`);
  if (!container) return;

  container.innerHTML = '<div class="flex items-center gap-2 text-neutral-400 text-xs py-4"><svg class="w-3.5 h-3.5 animate-spin" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3" opacity="0.2"/><path d="M12 2a10 10 0 019.95 9" stroke="currentColor" stroke-width="3" stroke-linecap="round"/></svg> Loading review detail...</div>';

  try {
    const detail = await asc(`version-review-detail get --version-id ${versionId} --output json`);
    const d = detail.data || detail;
    const updateCmd = `asc version-review-detail update --version-id ${versionId}`;

    container.innerHTML = `
      <div class="grid grid-cols-1 gap-3">
        ${editableField('Contact First Name', d.contactFirstName, updateCmd, '--contact-first-name')}
        ${editableField('Contact Last Name', d.contactLastName, updateCmd, '--contact-last-name')}
        ${editableField('Contact Email', d.contactEmail, updateCmd, '--contact-email')}
        ${editableField('Contact Phone', d.contactPhone, updateCmd, '--contact-phone')}
        ${editableField('Notes', d.notes, updateCmd, '--notes', { multiline: true })}
        ${detailRow('Demo Account Required', String(d.demoAccountRequired ?? false))}
      </div>`;
  } catch (err) {
    container.innerHTML = `<p class="text-xs text-neutral-400 py-2">No review detail set. ${linkButton('Create', `asc version-review-detail update --version-id ${versionId} --contact-first-name  --contact-last-name  --contact-email  --contact-phone `)}</p>`;
  }
}

function renderActionsTab(versionId, affordances) {
  return affordanceButtons(affordances, { exclude: ['submitForReview', 'checkReadiness'], class: '' }) || '<p class="text-xs text-neutral-400">No additional actions available.</p>';
}

// ── Event setup (called from index.html) ──────────────
export function setupEvents(refreshFn) {
  document.addEventListener('click', (e) => {
    // Version header click → expand/collapse
    const header = e.target.closest('.version-header');
    if (header) {
      const vid = header.dataset.versionId;
      const panel = document.getElementById(`version-detail-${vid}`);
      if (!panel) return;

      if (expandedVersionId === vid) {
        expandedVersionId = null;
        panel.classList.add('hidden');
        header.querySelector('svg').classList.remove('rotate-90');
      } else {
        // Collapse previous
        if (expandedVersionId) {
          const prev = document.getElementById(`version-detail-${expandedVersionId}`);
          if (prev) prev.classList.add('hidden');
          const prevHeader = document.querySelector(`[data-version-id="${expandedVersionId}"]`);
          if (prevHeader) prevHeader.querySelector('svg')?.classList.remove('rotate-90');
        }
        expandedVersionId = vid;
        panel.classList.remove('hidden');
        header.querySelector('svg').classList.add('rotate-90');
        loadVersionDetail(vid);
      }
      return;
    }

    // Tab switching
    const tab = e.target.closest('.version-tab');
    if (tab) {
      const tabName = tab.dataset.tab;
      const vid = tab.dataset.versionId;

      // Update tab styles
      tab.parentElement.querySelectorAll('.version-tab').forEach(t => {
        t.classList.remove('border-blue-600', 'text-blue-600');
        t.classList.add('border-transparent', 'text-neutral-400');
      });
      tab.classList.remove('border-transparent', 'text-neutral-400');
      tab.classList.add('border-blue-600', 'text-blue-600');

      // Load tab content
      if (tabName === 'localizations') loadVersionDetail(vid);
      else if (tabName === 'review') loadReviewDetailTab(vid);
      else if (tabName === 'actions') {
        const container = document.getElementById(`version-tab-content-${vid}`);
        // Find the version's affordances from the card
        const card = tab.closest('.bg-white');
        container.innerHTML = '<p class="text-xs text-neutral-400">Use the affordance buttons on each section to perform actions.</p>';
      }
      return;
    }
  });
}
