/**
 * Discord webhook proxy for LOR Alliance Academy.
 *
 * Setup:
 * 1. Go to https://script.google.com
 * 2. Create a new Apps Script project.
 * 3. Paste this file.
 * 4. Project Settings > Script Properties:
 *    DISCORD_WEBHOOK_URL = your Discord webhook URL
 * 5. Deploy > New deployment > Web app
 *    Execute as: Me
 *    Who has access: Anyone
 * 6. Copy the Web app URL into Academy Admin > Discord Proxy URL.
 */

function doPost(e) {
  try {
    var webhookUrl = PropertiesService.getScriptProperties().getProperty("DISCORD_WEBHOOK_URL");
    if (!webhookUrl) {
      return jsonResponse({ ok: false, error: "Missing DISCORD_WEBHOOK_URL script property" }, 500);
    }

    var payload = e && e.postData && e.postData.contents ? e.postData.contents : "{}";
    var response = UrlFetchApp.fetch(webhookUrl, {
      method: "post",
      contentType: "application/json",
      payload: payload,
      muteHttpExceptions: true
    });

    var code = response.getResponseCode();
    return jsonResponse({ ok: code >= 200 && code < 300, status: code, body: response.getContentText() }, code);
  } catch (error) {
    return jsonResponse({ ok: false, error: String(error) }, 500);
  }
}

function jsonResponse(data, statusCode) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
