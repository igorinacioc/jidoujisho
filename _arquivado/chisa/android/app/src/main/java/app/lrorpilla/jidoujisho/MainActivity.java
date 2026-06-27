// Derived from the AnkiDroid API Sample

package app.arianneorpilla.jidoujisho;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.app.ShareCompat;
import android.util.Log;
import android.util.SparseBooleanArray;
import android.view.ActionMode;
import android.view.ActionProvider;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.widget.AbsListView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;
import android.net.Uri;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.ryanheise.audioservice.AudioServicePlugin;
import com.ichi2.anki.api.AddContentApi;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MainActivity extends FlutterActivity {
    private static final String ANKIDROID_CHANNEL = "com.arianneorpilla.api/ankidroid";

    private static final int AD_PERM_REQUEST = 0;

    private Activity context;
    private AnkiDroidHelper mAnkiDroid;

    @Override
    public FlutterEngine provideFlutterEngine(Context context) {
        return AudioServicePlugin.getFlutterEngine(context);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        context = MainActivity.this;
        // Create the example data
        mAnkiDroid = new AnkiDroidHelper(context);
    }

    /**
     * Add a note to AnkiDroid using a specified model and field mapping.
     * If modelName is null, defaults to "jidoujisho Chisa" with 8 fixed fields.
     *
     * @param deck       Deck name
     * @param modelName  Model name (null = default "jidoujisho Chisa")
     * @param fields     Map of field names → field values (for custom models)
     * @param params     Legacy flat params for backward compatibility
     */
    private void addNote(String deck, String modelName, Map<String, String> fields,
                         String sentence, String word, String reading, String meaning,
                         String image, String audio, String extra, String contextParam) {
        final AddContentApi api = new AddContentApi(context);

        long deckId;
        if (deckExists(deck)) {
            deckId = mAnkiDroid.findDeckIdByName(deck);
        } else {
            deckId = api.addNewDeck(deck);
        }

        // Use custom model if provided, otherwise fall back to default
        String effectiveModelName = (modelName != null && !modelName.isEmpty())
            ? modelName
            : "jidoujisho Chisa";

        long modelId;
        Long foundModelId = mAnkiDroid.findModelIdByName(effectiveModelName, 1);
        if (foundModelId != null) {
            modelId = foundModelId;
        } else {
            // Model doesn't exist — create default "jidoujisho Chisa" model
            modelId = api.addNewCustomModel("jidoujisho Chisa",
                new String[] {
                    "Sentence",
                    "Word",
                    "Reading",
                    "Meaning",
                    "Image",
                    "Audio",
                    "Extra",
                    "Context",
                },
                new String[] {
                    "jidoujisho Chisa Default"
                },
                new String[] {"<p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div>"},
                    new String[] {"<p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div><br>{{Audio}}<div class=\"image\">{{Image}}</div><hr id=reading><p id=\"reading\">{{Reading}}</p><h2 id=\"word\">{{Word}}</h2><br><p><small id=\"meaning\">{{Meaning}}</small></p><br>{{#Context}}<a style=\"text-decoration:none;color:red;\" href=\"{{Context}}\">↩</a>{{/Context}}"},
                            "p {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            "h2 {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            "small {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            ".card {\n" +
                            "  font-family: arial;\n" +
                            "  font-size: 20px;\n" +
                            "  text-align: center;\n" +
                            "  color: black;\n" +
                            "  background-color: white;\n" +
                            "  white-space: pre-line;\n" +
                            "}\n" +
                            "\n" +
                            "#sentence {\n" +
                            "    font-size: 30px\n" +
                            "}\n" +
                            "\n" +
                            ".context.night_mode {\n" +
                            "    text-decoration: none;\n" +
                            "    color: red;\n" +
                            "}\n" +
                            ".context {\n" +
                            "    text-decoration: none;\n" +
                            "    color: red;\n" +
                            "}\n" +
                            "\n" +
                            ".image img {\n" +
                            "  position: static;\n" +
                            "  height: auto;\n" +
                            "  width: auto;\n" +
                            "  max-height: 250px;\n" +
                            "}\n" +
                            ".pitch{\n" +
                            "  border-top: solid red 2px;\n" +
                            "  padding-top: 1px;\n" +
                            "}\n" +
                            "\n" +
                            ".pitch_end{\n" +
                            "  border-color: red;\n" +
                            "  border-right: solid red 2px;\n" +
                            "  border-top: solid red 2px;  \n" +
                            "  line-height: 1px;\n" +
                            "  margin-right: 1px;\n" +
                            "  padding-right: 1px;\n" +
                            "  padding-top:1px;\n" +
                            "}",
                    null,
                    null
                    );
        }

        Set<String> tags = new HashSet<>(Arrays.asList("Chisa"));

        // Build fields array in model field order, using mapping or defaults
        String[] modelFields = api.getFieldList(modelId);
        if (modelFields == null) {
            System.out.println("ERROR: Could not get field list for model " + modelId);
            return;
        }

        String[] finalFields = new String[modelFields.length];

        for (int i = 0; i < modelFields.length; i++) {
            String fieldName = modelFields[i];

            // If we have a field mapping (custom model), use it
            if (fields != null && fields.containsKey(fieldName)) {
                finalFields[i] = fields.get(fieldName);
            } else {
                // Fall back to legacy mapping by field name
                finalFields[i] = getLegacyFieldValue(fieldName,
                    sentence, word, reading, meaning, image, audio, extra, contextParam);
            }
        }

        api.addNote(modelId, deckId, finalFields, tags);

        System.out.println("Added note via flutter_ankidroid_api");
        System.out.println("Model: " + modelId + " (" + effectiveModelName + ")");
        System.out.println("Deck: " + deckId);
        System.out.println("Fields count: " + finalFields.length);
    }

    /**
     * Maps legacy field names to their values for backward compatibility.
     * Handles case-insensitive matching.
     */
    private String getLegacyFieldValue(String fieldName,
            String sentence, String word, String reading, String meaning,
            String image, String audio, String extra, String contextParam) {
        String lower = fieldName.toLowerCase().trim();
        if (lower.equals("sentence")) return sentence;
        if (lower.equals("word")) return word;
        if (lower.equals("reading")) return reading;
        if (lower.equals("meaning")) return meaning;
        if (lower.equals("image")) return image;
        if (lower.equals("audio")) return audio;
        if (lower.equals("extra")) return extra;
        if (lower.equals("context")) return contextParam;
        // For unknown fields, return empty string
        return "";
    }

    /**
     * Fetch all available models from AnkiDroid with their field lists.
     * Returns a map: modelName → [fieldName1, fieldName2, ...]
     */
    private Map<String, List<String>> getModels() {
        final AddContentApi api = new AddContentApi(context);
        Map<Long, String> modelList = api.getModelList(1); // all models with >= 1 field
        Map<String, List<String>> result = new java.util.HashMap<>();

        if (modelList != null) {
            for (Map.Entry<Long, String> entry : modelList.entrySet()) {
                String[] fields = api.getFieldList(entry.getKey());
                if (fields != null) {
                    result.put(entry.getValue(), Arrays.asList(fields));
                }
            }
        }
        return result;
    }

    /**
     * Get field list for a specific model by name.
     */
    private List<String> getModelFields(String modelName, int minFields) {
        final AddContentApi api = new AddContentApi(context);
        Map<Long, String> modelList = api.getModelList(minFields >= 1 ? minFields : 1);

        if (modelList != null) {
            for (Map.Entry<Long, String> entry : modelList.entrySet()) {
                if (entry.getValue().equals(modelName)) {
                    String[] fields = api.getFieldList(entry.getKey());
                    if (fields != null) {
                        return Arrays.asList(fields);
                    }
                }
            }
        }
        return new ArrayList<>();
    }

    /**
     * Create a new model in AnkiDroid with the given field names.
     * Uses simple default card templates.
     */
    private String addNewModel(String modelName, List<String> fieldNames) {
        final AddContentApi api = new AddContentApi(context);

        String[] fields = fieldNames.toArray(new String[0]);
        String[] cardNames = new String[] { modelName + " Card" };

        // Simple default templates: front = first field, back = all fields
        String qfmt = buildSimpleQfmt(fields);
        String afmt = buildSimpleAfmt(fields);

        String css = ".card {\n  font-family: arial;\n  font-size: 20px;\n  text-align: center;\n  color: black;\n  background-color: white;\n}\n";

        Long modelId = api.addNewCustomModel(modelName, fields, cardNames,
            new String[] { qfmt }, new String[] { afmt }, css, null, null);

        if (modelId != null) {
            mAnkiDroid.storeModelReference(modelName, modelId);
            System.out.println("Created new model: " + modelName + " with " + fields.length + " fields");
            return modelName;
        }
        return null;
    }

    private String buildSimpleQfmt(String[] fields) {
        StringBuilder sb = new StringBuilder();
        for (String field : fields) {
            sb.append("<div class=\"").append(field.toLowerCase()).append("\">{{").append(field).append("}}</div>\n");
        }
        return sb.toString();
    }

    private String buildSimpleAfmt(String[] fields) {
        // Back template: front side content + extra formatting
        StringBuilder sb = new StringBuilder();
        sb.append("{{FrontSide}}\n<hr id=answer>\n");
        for (String field : fields) {
            sb.append("<div class=\"").append(field.toLowerCase()).append("\">{{").append(field).append("}}</div>\n");
        }
        return sb.toString();
    }

    private boolean deckExists(String deck) {
        Long deckId = mAnkiDroid.findDeckIdByName(deck);
        return (deckId != null);
    }

    private boolean modelExists(String model) {
        Long deckId = mAnkiDroid.findModelIdByName(model, 1);
        return (deckId != null);
    }

    private Long getDeckId() {
        Long did = mAnkiDroid.findDeckIdByName(AnkiDroidConfig.DECK_NAME);
        if (did == null) {
            did = mAnkiDroid.getApi().addNewDeck(AnkiDroidConfig.DECK_NAME);
            mAnkiDroid.storeDeckReference(AnkiDroidConfig.DECK_NAME, did);
        }
        return did;
    }

    private Long getModelId() {
        Long mid = mAnkiDroid.findModelIdByName(AnkiDroidConfig.MODEL_NAME, AnkiDroidConfig.FIELDS.length);
        if (mid == null) {
            mid = mAnkiDroid.getApi().addNewCustomModel(AnkiDroidConfig.MODEL_NAME, AnkiDroidConfig.FIELDS,
                AnkiDroidConfig.CARD_NAMES, AnkiDroidConfig.QFMT, AnkiDroidConfig.AFMT, AnkiDroidConfig.CSS, getDeckId(), null);
            mAnkiDroid.storeModelReference(AnkiDroidConfig.MODEL_NAME, mid);
        }
        return mid;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), ANKIDROID_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    final String deck = call.argument("deck");
                    final String sentence = call.argument("sentence");
                    final String word = call.argument("word");
                    final String meaning = call.argument("meaning");
                    final String reading = call.argument("reading");
                    final String image = call.argument("image");
                    final String audio = call.argument("audio");
                    final String extra = call.argument("extra");
                    final String contextParam = call.argument("contextParam");

                    final String fileUriPath = call.argument("fileUriPath");
                    final String preferredName = call.argument("preferredName");
                    final String mimeType = call.argument("mimeType");
                    final AddContentApi api = new AddContentApi(context);

                    switch (call.method) {
                        case "addNote": {
                            String modelName = call.argument("modelName");
                            Map<String, String> fieldMap = null;
                            if (call.hasArgument("fields")) {
                                Map<Object, Object> rawMap = call.argument("fields");
                                if (rawMap != null) {
                                    fieldMap = new java.util.HashMap<>();
                                    for (Map.Entry<Object, Object> e : rawMap.entrySet()) {
                                        fieldMap.put(e.getKey().toString(),
                                            e.getValue() != null ? e.getValue().toString() : "");
                                    }
                                }
                            }
                            addNote(deck, modelName, fieldMap,
                                sentence, word, reading, meaning, image, audio, extra, contextParam);
                            result.success("Added note");
                            break;
                        }
                        case "getDecks":
                            result.success(api.getDeckList());
                            break;
                        case "getModels":
                            result.success(getModels());
                            break;
                        case "getModelFields": {
                            String modelName = call.argument("modelName");
                            int minFields = call.argument("minFields") != null
                                ? Integer.parseInt(call.argument("minFields").toString()) : 1;
                            result.success(getModelFields(modelName, minFields));
                            break;
                        }
                        case "addNewModel": {
                            String modelName = call.argument("modelName");
                            List<String> fieldNames = new ArrayList<>();
                            Object rawFields = call.argument("fieldNames");
                            if (rawFields instanceof List) {
                                for (Object f : (List<?>) rawFields) {
                                    fieldNames.add(f.toString());
                                }
                            }
                            String created = addNewModel(modelName, fieldNames);
                            result.success(created);
                            break;
                        }
                        case "requestPermissions":
                            if (mAnkiDroid.shouldRequestPermission()) {
                                mAnkiDroid.requestPermission(MainActivity.this, AD_PERM_REQUEST);
                            }
                            break;
                        case "addMediaFromUri":
                            System.out.println(fileUriPath);
                            System.out.println(preferredName);
                            System.out.println(mimeType);
                            Uri fileUri = Uri.parse(fileUriPath);

                            try {
                                String addedFileName = api.addMediaFromUri(fileUri, preferredName, mimeType);
                                result.success(addedFileName);
                                System.out.println("Added media from URI");
                            } catch (Exception e) {
                                System.out.println(e);
                            }


                            break;
                        default:
                            result.notImplemented();
                    }
                }

            );
    }
}