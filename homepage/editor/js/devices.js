// DEVICES array with screen offset metadata for flood-fill compositor
const DEVICES = [
  // iPhone
  { name: "iPhone 14 Pro Landscape", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 14 Pro Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 14 Pro Max Landscape", x: 70, y: 80, category: "iPhone" },
  { name: "iPhone 14 Pro Max Portrait", x: 80, y: 70, category: "iPhone" },
  { name: "iPhone 15 Pro - Natural Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 15 Pro - Black Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 15 Pro - Blue Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 15 Pro - White Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 15 Pro Max - Natural Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 15 Pro Max - Black Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 15 Pro Max - Blue Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 15 Pro Max - White Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 - White - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 - Black - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 - Pink - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 - Teal - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 - Ultramarine - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 Pro - Natural Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 Pro - Black Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 Pro - White Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 Pro - Desert Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 Pro Max - Natural Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 Pro Max - Black Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 Pro Max - White Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 16 Pro Max - Desert Titanium - Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 8 and 2020 SE", x: 125, y: 334, category: "iPhone" },
  { name: "iPhone 12-13 mini Landscape", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 12-13 mini Portrait", x: 80, y: 80, category: "iPhone" },
  { name: "iPhone 12-13 Pro Landscape", x: 84, y: 115, category: "iPhone" },
  { name: "iPhone 12-13 Pro Portrait", x: 115, y: 84, category: "iPhone" },
  { name: "iPhone 12-13 Pro Max Landscape", x: 111, y: 108, category: "iPhone" },
  { name: "iPhone 12-13 Pro Max Portrait", x: 108, y: 111, category: "iPhone" },
  { name: "iPhone 11 Pro Max Landscape", x: 155, y: 179, category: "iPhone" },
  { name: "iPhone 11 Pro Max Portrait", x: 179, y: 155, category: "iPhone" },
  { name: "iPhone 11 Pro Portrait", x: 238, y: 182, category: "iPhone" },
  { name: "iPhone 11 Landscape", x: 104, y: 86, category: "iPhone" },
  { name: "iPhone 11 Portrait", x: 86, y: 104, category: "iPhone" },
  // iPad
  { name: "iPad mini 2021 Landscape", x: 142, y: 146, category: "iPad" },
  { name: "iPad mini 2021 Portrait", x: 146, y: 142, category: "iPad" },
  { name: "iPad 2021 Landscape", x: 250, y: 110, category: "iPad" },
  { name: "iPad 2021 Portrait", x: 110, y: 250, category: "iPad" },
  { name: "iPad Air 2020 Landscape", x: 140, y: 139, category: "iPad" },
  { name: "iPad Air 2020 Portrait", x: 139, y: 140, category: "iPad" },
  { name: "iPad Pro 2018-2021 11 Landscape", x: 120, y: 120, category: "iPad" },
  { name: "iPad Pro 2018-2021 11 Portrait", x: 120, y: 120, category: "iPad" },
  { name: "iPad Pro 2018-2021 Landscape", x: 120, y: 120, category: "iPad" },
  { name: "iPad Pro 2018-2021 Portrait", x: 120, y: 120, category: "iPad" },
  { name: "iPad Pro 13 - M4 - Silver - Portrait", x: 120, y: 120, category: "iPad" },
  { name: "iPad Pro 13 - M4 - Space Gray - Portrait", x: 120, y: 120, category: "iPad" },
  // iPad Air M2
  { name: "iPad Air 11\" - M2 - Blue - Landscape", x: 120, y: 120, category: "iPad" },
  { name: "iPad Air 11\" - M2 - Blue - Portrait", x: 120, y: 120, category: "iPad" },
  { name: "iPad Air 11\" - M2 - Purple - Landscape", x: 120, y: 120, category: "iPad" },
  { name: "iPad Air 11\" - M2 - Purple - Portrait", x: 120, y: 120, category: "iPad" },
  { name: "iPad Air 13\" - M2 - Blue - Landscape", x: 120, y: 120, category: "iPad" },
  { name: "iPad Air 13\" - M2 - Blue - Portrait", x: 120, y: 120, category: "iPad" },
  // iPad Silver
  { name: "iPad - Silver - Landscape", x: 120, y: 120, category: "iPad" },
  { name: "iPad - Silver - Portrait", x: 120, y: 120, category: "iPad" },
  // Mac
  { name: "MacBook Air 2020", x: 620, y: 652, category: "Mac" },
  { name: "iMac 2021", x: 141, y: 161, category: "Mac" },
  { name: "MacBook Pro 2021 14", x: 460, y: 300, category: "Mac" },
  { name: "MacBook Pro 2021 16", x: 442, y: 313, category: "Mac" },
  { name: "MacBook Air 2022", x: 330, y: 218, category: "Mac" },
  { name: "iMac 24\" - Silver", x: 141, y: 161, category: "Mac" },
  // Watch
  { name: "Watch Ultra 2022", x: 95, y: 219, category: "Watch" },
  { name: "Watch Series 4 44", x: 66, y: 222, category: "Watch" },
  { name: "Watch Series 4 40", x: 114, y: 308, category: "Watch" },
  { name: "Watch Series 7 45 Midnight", x: 72, y: 188, category: "Watch" },
  { name: "Watch Series 7 45 Starlight", x: 72, y: 188, category: "Watch" },
];

// Display type dimensions (output canvas size for App Store)
const DISPLAY_TYPE_SIZES = {
  "APP_IPHONE_67":          { width: 1290, height: 2796 },
  "APP_IPHONE_65":          { width: 1242, height: 2688 },
  "APP_IPHONE_61":          { width: 1179, height: 2556 },
  "APP_IPHONE_55":          { width: 1242, height: 2208 },
  "APP_IPHONE_47":          { width: 750,  height: 1334 },
  "APP_IPAD_PRO_3GEN_129":  { width: 2048, height: 2732 },
  "APP_IPAD_PRO_3GEN_11":   { width: 1668, height: 2388 },
  "APP_IPAD_PRO_129":       { width: 2048, height: 2732 },
  "APP_IPAD_105":           { width: 1668, height: 2224 },
  "APP_IPAD_97":            { width: 1536, height: 2048 },
  "APP_WATCH_ULTRA":        { width: 410,  height: 502  },
  "IMESSAGE_APP_IPHONE_67": { width: 1290, height: 2796 },
};

function populateDeviceDropdown(selectEl) {
  const categories = ['iPhone', 'iPad', 'Mac', 'Watch'];
  categories.forEach(cat => {
    const group = document.createElement('optgroup');
    group.label = cat;
    DEVICES.filter(d => d.category === cat).forEach(d => {
      const opt = document.createElement('option');
      opt.value = d.name;
      opt.textContent = d.name;
      group.appendChild(opt);
    });
    selectEl.appendChild(group);
  });
}
