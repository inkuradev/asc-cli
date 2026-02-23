// ZIP export using JSZip

async function exportToZip(state) {
  const zip = new JSZip();
  const manifest = {
    version: "1.0",
    exportedAt: new Date().toISOString(),
    localizations: {}
  };

  for (const [locale, locData] of Object.entries(state.locales)) {
    manifest.localizations[locale] = {
      displayType: locData.displayType,
      screenshots: []
    };
    const locFolder = zip.folder(locale);
    const outSize = DISPLAY_TYPE_SIZES[locData.displayType] || { width: 1290, height: 2796 };

    for (const ss of locData.screenshots) {
      const order = ss.order;
      const filename = `${order}.png`;
      const blob = await exportScreenshotToPNG(ss, outSize);
      if (blob) {
        locFolder.file(filename, blob);
      }
      manifest.localizations[locale].screenshots.push({
        order,
        file: `${locale}/${filename}`,
        device: ss.device || null,
        background: ss.background || null,
        texts: ss.texts || []
      });
    }
  }

  zip.file('manifest.json', JSON.stringify(manifest, null, 2));
  const content = await zip.generateAsync({ type: 'blob' });
  const url = URL.createObjectURL(content);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'export.zip';
  a.click();
  setTimeout(() => URL.revokeObjectURL(url), 5000);
}
