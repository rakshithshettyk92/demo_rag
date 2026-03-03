"""
src/esl/fabric_json_builder.py
-------------------------------
Converts a layout spec dict into a Fabric.js canvas JSON (v2.3.4 format).

The output JSON can be loaded back into the Solum template designer for
future edits — preserving the full edit-regenerate workflow.
"""

import json
import time


def _base_object(eid: int, etype: str) -> dict:
    return {
        "type": etype,
        "version": "2.3.4",
        "originX": "left",
        "originY": "top",
        "angle": 0,
        "flipX": False,
        "flipY": False,
        "opacity": 1,
        "shadow": None,
        "visible": True,
        "clipTo": None,
        "fillRule": "nonzero",
        "paintFirst": "fill",
        "globalCompositeOperation": "source-over",
        "transformMatrix": None,
        "skewX": 0,
        "skewY": 0,
        "id": eid,
        "isLock": False,
        "lockRotation": False,
        "lockScalingY": False,
        "lockScalingX": False,
        "lockMovementX": False,
        "lockMovementY": False,
        "borderColor": "rgba(102,153,255,0.75)",
        "cornerColor": "rgba(102,153,255,0.5)",
        "isOpenExistingTemplate": True,
        "layerId": "0",
        "pageNumber": 1,
        "conditionArray": [],
        "conditionResults": [],
        "hideFieldByDefault": False,
    }


def _textbox_object(el: dict, eid: int) -> dict:
    field = el.get("field")
    static = el.get("static_text")
    text_value = f"##{field}##" if field and not static else (static or "")
    name_value = field if field and not static else "TextBox"

    obj = _base_object(eid, "textbox")
    obj.update({
        "left": el["x"],
        "top": el["y"],
        "width": el["width"],
        "height": el["height"],
        "fill": el.get("fill", "black"),
        "stroke": None,
        "strokeWidth": 1,
        "backgroundColor": el.get("background_color", "transparent"),
        "text": text_value,
        "fontSize": el.get("font_size", 14),
        "fontWeight": "bold" if el.get("font_weight") == "bold" else "",
        "fontFamily": el.get("font_family", "Arial"),
        "fontStyle": "italic" if el.get("font_style") == "italic" else "",
        "lineHeight": 1.16,
        "underline": False,
        "overline": False,
        "linethrough": False,
        "textAlign": el.get("text_align", "left"),
        "textVertAlign": el.get("text_vert_align", "top"),
        "textBackgroundColor": "",
        "charSpacing": 0,
        "minHeight": 36,
        "name": name_value,
        "value": name_value,
        "textWrap": False,
        "fitText": el.get("fit_text", False),
        "isScalingTextFit": False,
        "isScalingTextFitUpscalingAllowed": False,
        "isZeroformatEnabled": True,
        "minWidth": 10,
        "editable": False,
        "isShadow": False,
        "priceEnabled": False,
        "priceDescriptionType": "Currency Only",
        "isBackgroundVisible": False,
        "defaultDropdownValue": "",
        "mergeDropdownName": "Additional Field",
        "mergeUserInputBeforeValue": "",
        "mergeUserInputValue": "",
        "mergeAnotherUserInputValue": "",
        "mergeRelatedData": [],
        "operationOptionModification": "",
        "calculationDropdownName": "Value",
        "calculationDropdownNameProductNumber": "",
        "calculationUserInputValue": "",
        "calculationDivFomatOptionSelected": "",
        "calcOptionFirstOperator": "",
        "calcOptionFirstOperatorCount": 1,
        "calcOptionFieldModCalculation": "",
        "calcOptionFieldModCalculationCount": "",
        "calcOptionLastOperator": "",
        "calcOptionLastOperatorCount": 1,
        "calculationRelatedData": [],
        "defaultDropdownName": "",
        "defaultDropdownNameProductNumber": "",
        "calculationDivisionFormat": "",
        "productNumber": 1,
        "currencyFormatType": "",
        "isThousandSeperator": False,
        "isIndianCurrency": False,
        "customCurrencyFormatName": "",
        "customCurrencyThousandSeparator": True,
        "currencySignDisplacementRatioWithFontSizeX": "",
        "currencySignDisplacementRatioWithFontSizeY": "",
        "currencyIsDecimalSeperatorVisible": "true",
        "currencyDecimalSeperatorDisplacementRatioWithFontSizeX": "",
        "currencyDecimalSeperatorDisplacementRatioWithFontSizeY": "",
        "currencyIsDecimalPortionVisible": True,
        "currencyDecimalPortionDisplacementRatioWithFontSizeX": "",
        "currencyDecimalPortionDisplacementRatioWithFontSizeY": "",
        "isCustomCurrencyFormat": False,
        "currencySizeRatioWithFontSize": 1,
        "currencyDecimalSeperatorSizeRatioWithFontSize": 1,
        "currencyDecimalPortionSizeRatioWithFontSize": 1,
        "customCurrencyPosition": "start",
        "currencyCode": "",
        "originalFill": el.get("fill", "black"),
        "originalBackgroundColor": el.get("background_color", "transparent"),
        "isCurrencyFormatSet": False,
        "fxDetails": [],
        "isFxDetailsGiven": False,
        "svgFilter": "no_filter",
        "textFitMin": 5,
        "textFitMax": 100,
        "isToApplyUpperCase": False,
        "isToApplyLowerCase": False,
        "orignalStaticTextBeforeUpperCaseAndLowerCase": "",
        "hyphenation": False,
        "hyphenationLaguage": "en-us",
        "hyphenationOverflowHide": True,
        "letterSpacing": 0,
        "aliasName": name_value if field and not static else "",
        "aliasNameFlag": False,
        "calculationDivRoundOptionSelected": "default",
        "codeSnippet": "",
        "IsXslScript": False,
        "styles": {},
    })
    return obj


def _rect_object(el: dict, eid: int) -> dict:
    import math
    obj = _base_object(eid, "rect")
    obj.update({
        "left": el["x"],
        "top": el["y"],
        "width": el["width"],
        "height": el["height"],
        "fill": el.get("fill", "transparent"),
        "stroke": el.get("stroke", "black"),
        "strokeWidth": el.get("stroke_width", 1),
        "backgroundColor": "",
        "scaleX": 1,
        "scaleY": 1,
        "rx": 0,
        "ry": 0,
        "isSetBackground": False,
        "isBackgroundVisible": False,
        "productNumber": 1,
        "shapeName": "rectangle",
        "rectangleShapeRadius": 0,
    })
    return obj


def _barcode_object(el: dict, eid: int) -> dict:
    field = el.get("field", "ITEM_ID")
    obj = _base_object(eid, "group")
    obj.update({
        "left": el["x"],
        "top": el["y"],
        "width": el["width"],
        "height": el["height"],
        "fill": "rgb(0,0,0)",
        "stroke": None,
        "strokeWidth": 0,
        "backgroundColor": "",
        "isBarcode": True,
        "barcodeIndex": 1,
        "barcodeType": el.get("barcode_type", "code128"),
        "barcodeDataLink": field,
        "barcodeXslTypeName": el.get("barcode_type", "code128"),
        "dataMatrixBarcodeShape": "force-none",
        "dataMatrixMinSymbol": "",
        "dataMatrixMaxSymbol": "",
        "dataMatrixQuiteZoneEnabled": False,
        "dataMatrixQuiteZoneValue": "10",
        "barcodeHeight": el["height"],
        "barcodeWidth": str(el["width"]),
        "barcodeModule": 1,
        "barcodeBackgroundColor": "white",
        "productNumber": 1,
        "barcodeHumanReadable": "none",
        "wideFactor": 4,
        "moduleWidthTextBoxValue": "0.1",
        "barcodeConfig": "0",
        "barcodeModuleSize": "4",
        "aztecType": "0",
        "aztecMargin": "0",
        "barcodealign": "left",
        "barcodeHRFontSize": 12,
        "barcodeDataTrimLength": 0,
        "barcodeDataTrimPosition": "start",
        "objects": [],  # inner text/image children omitted (designer re-generates)
    })
    return obj


def build_fabric_json(layout: dict, template_name: str = "AI_GENERATED") -> str:
    """
    Convert a layout spec dict into a Fabric.js canvas JSON string.

    Args:
        layout: layout spec as produced by ESLGenerator.generate()
        template_name: name to embed in the canvas metadata

    Returns:
        JSON string loadable in the Solum template designer
    """
    canvas = layout["canvas"]
    elements = layout["elements"]
    base_id = int(time.time() * 1000)

    objects = []
    for i, el in enumerate(elements):
        eid = base_id + i
        etype = el.get("type")
        if etype == "textbox":
            objects.append(_textbox_object(el, eid))
        elif etype == "rect":
            objects.append(_rect_object(el, eid))
        elif etype == "barcode":
            objects.append(_barcode_object(el, eid))

    canvas_doc = [
        {
            "version": "2.3.4",
            "objects": objects,
            "backgroundColor": canvas.get("background_color", "#FFFFFF"),
            "width": canvas["width"],
            "height": canvas["height"],
            "name": template_name,
            "isCanvas": True,
            "stationCode": "1",
            "type": "",
            "data": "",
            "fileName": None,
            "json": "",
            "prop_name": template_name,
            "isMultiProduct": False,
            "pageNumber": 1,
            "isMultipage": False,
            "LDversion": "v25.04.4",
            "rotateClockwiseCount": 0,
            "rotateCounterClockwiseCount": 0,
            "layoutColor": "4_COLOR",
            "layers": [
                {
                    "Id": "0",
                    "Name": "All",
                    "isLayerNameEdit": False,
                    "selected": True,
                    "layerCounter": 0,
                    "layerConditionArray": [],
                    "formattedCondition": "",
                }
            ],
            "videDetails": [],
            "imageDetails": [],
            "codeSnippet": "",
        }
    ]

    return json.dumps(canvas_doc, ensure_ascii=False)
