/**
 * RSVP collector for the wedding site.
 *
 * Setup (5 minutes):
 *  1. Create a Google Sheet → Extensions → Apps Script, paste this file, save.
 *  2. Deploy → New deployment → type "Web app" → Execute as: Me, Who has access: Anyone → Deploy.
 *  3. Copy the web-app URL into SHEET_URL in index.html.
 */
function doPost(e) {
  const p = (e && e.parameter) || {};
  const book = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = book.getSheetByName('RSVP') || book.insertSheet('RSVP');
  if (sheet.getLastRow() === 0) sheet.appendRow(['Time', 'Name', 'Joining', 'Message', 'Sent to']);

  // Trim, cap length, and stop anything that looks like a formula from executing.
  const clean = (v, max) => {
    const s = String(v || '').trim().slice(0, max);
    return /^[=+\-@]/.test(s) ? "'" + s : s;
  };
  sheet.appendRow([new Date(), clean(p.name, 120), clean(p.joining, 80), clean(p.message, 1000), clean(p.to, 80)]);
  return ContentService.createTextOutput('ok');
}
