// Device registry — loaded from frames/devices.json (the single source of truth).
// DEVICES_MAP  { [frameName]: { category, displayType, outputWidth, outputHeight, screenInsetX, screenInsetY } }
// DEVICES_LIST array form for the device dropdown
// DISPLAY_TYPE_SIZES { [displayType]: { width, height } } — derived: first portrait size per type

let DEVICES_MAP = {};
let DEVICES_LIST = [];

// Canonical App Store screenshot dimensions per display type slot.
// These are the sizes App Store Connect expects for each slot — independent of
// which specific device frame the user picks for the visual preview.
const DISPLAY_TYPE_SIZES = {
  "APP_IPHONE_67":          { width: 1290, height: 2796 },
  "APP_IPHONE_65":          { width: 1242, height: 2688 },
  "APP_IPHONE_61":          { width: 1179, height: 2556 },
  "APP_IPHONE_58":          { width: 1125, height: 2436 },
  "APP_IPHONE_55":          { width: 1242, height: 2208 },
  "APP_IPHONE_47":          { width:  750, height: 1334 },
  "APP_IPHONE_40":          { width:  640, height: 1136 },
  "APP_IPAD_PRO_3GEN_129":  { width: 2048, height: 2732 },
  "APP_IPAD_PRO_3GEN_11":   { width: 1668, height: 2388 },
  "APP_IPAD_PRO_129":       { width: 2048, height: 2732 },
  "APP_IPAD_105":           { width: 1668, height: 2224 },
  "APP_IPAD_97":            { width: 1536, height: 2048 },
  "APP_DESKTOP":            { width: 2880, height: 1800 },
  "APP_WATCH_ULTRA":        { width:  410, height:  502 },
  "APP_WATCH_SERIES_10":    { width:  410, height:  502 },
  "APP_WATCH_SERIES_7":     { width:  396, height:  484 },
  "APP_WATCH_SERIES_4":     { width:  368, height:  448 },
  "IMESSAGE_APP_IPHONE_67": { width: 1290, height: 2796 },
  "IMESSAGE_APP_IPHONE_65": { width: 1242, height: 2688 },
  "IMESSAGE_APP_IPHONE_61": { width: 1179, height: 2556 },
};

async function initDevices() {
  const resp = await fetch('frames/devices.json');
  DEVICES_MAP = await resp.json();
  delete DEVICES_MAP['_comment'];
  DEVICES_LIST = Object.entries(DEVICES_MAP).map(([name, d]) => ({ name, ...d }));
}

function populateDeviceDropdown(selectEl) {
  const categories = ['iPhone', 'iPad', 'Mac', 'Watch'];
  categories.forEach(cat => {
    const devices = DEVICES_LIST.filter(d => d.category === cat);
    if (!devices.length) return;
    const group = document.createElement('optgroup');
    group.label = cat;
    devices.forEach(d => {
      const opt = document.createElement('option');
      opt.value = d.name;
      opt.textContent = d.name;
      group.appendChild(opt);
    });
    selectEl.appendChild(group);
  });
}
