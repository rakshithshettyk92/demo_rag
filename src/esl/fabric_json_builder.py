"""
src/esl/fabric_json_builder.py
-------------------------------
Converts a layout spec dict into a Fabric.js canvas JSON (v2.3.4 format).

The output JSON can be loaded back into the Solum template designer for
future edits — preserving the full edit-regenerate workflow.
"""

import json
import time
from src.esl.currency_registry import CURRENCY_REGISTRY


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

    # ── Currency resolution ───────────────────────────────────────────────
    currency_code   = el.get("currency_code") or ""
    currency_format = el.get("currency_format") or ""
    cur_info        = CURRENCY_REGISTRY.get(currency_code, {}) if currency_code else {}
    is_currency_set = bool(currency_code and cur_info)
    is_indian       = cur_info.get("indian", False)
    has_thousand    = bool(cur_info.get("thousand_sep"))

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
        "lineHeight": el.get("line_height", 1.16),
        "underline": el.get("underline", False),
        "overline": el.get("overline", False),
        "linethrough": el.get("line_through", False),
        "textAlign": el.get("text_align", "left"),
        "textVertAlign": el.get("text_vert_align", "top"),
        "textBackgroundColor": "",
        "charSpacing": el.get("letter_spacing", 0),
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
        "priceEnabled": is_currency_set,
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
        "currencyFormatType": currency_format,
        "isThousandSeperator": has_thousand,
        "isIndianCurrency": is_indian,
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
        "currencyCode": currency_code,
        "originalFill": el.get("fill", "black"),
        "originalBackgroundColor": el.get("background_color", "transparent"),
        "isCurrencyFormatSet": is_currency_set,
        "fxDetails": [],
        "isFxDetailsGiven": False,
        "svgFilter": "no_filter",
        "textFitMin": el.get("text_fit_min", 5),
        "textFitMax": el.get("text_fit_max", 100),
        "isToApplyUpperCase": el.get("upper_case", False),
        "isToApplyLowerCase": el.get("lower_case", False),
        "orignalStaticTextBeforeUpperCaseAndLowerCase": "",
        "hyphenation": False,
        "hyphenationLaguage": "en-us",
        "hyphenationOverflowHide": el.get("overflow_hide", True),
        "letterSpacing": el.get("letter_spacing", 0),
        "aliasName": name_value if field and not static else "",
        "aliasNameFlag": False,
        "calculationDivRoundOptionSelected": "default",
        "codeSnippet": "",
        "IsXslScript": False,
        "styles": {},
    })
    return obj


def _rect_object(el: dict, eid: int) -> dict:
    border_radius = el.get("border_radius", 0)
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
        "rx": border_radius,
        "ry": border_radius,
        "isSetBackground": False,
        "isBackgroundVisible": False,
        "productNumber": 1,
        "shapeName": "rectangle",
        "rectangleShapeRadius": border_radius,
    })
    return obj


def _circle_object(el: dict, eid: int) -> dict:
    rx = round(el["width"] / 2)
    ry = round(el["height"] / 2)
    obj = _base_object(eid, "ellipse")
    obj.update({
        "left": el["x"],
        "top": el["y"],
        "width": el["width"],
        "height": el["height"],
        "rx": rx,
        "ry": ry,
        "fill": el.get("fill", "transparent"),
        "stroke": el.get("stroke", "black"),
        "strokeWidth": el.get("stroke_width", 1),
        "backgroundColor": "",
        "scaleX": 1,
        "scaleY": 1,
        "isSetBackground": False,
        "isBackgroundVisible": False,
        "productNumber": 1,
        "shapeName": "ellipse",
    })
    return obj


def _line_object(el: dict, eid: int) -> dict:
    x1_abs = el.get("x1", 0)
    y1_abs = el.get("y1", 0)
    x2_abs = el.get("x2", 0)
    y2_abs = el.get("y2", 0)

    left   = min(x1_abs, x2_abs)
    top    = min(y1_abs, y2_abs)
    width  = abs(x2_abs - x1_abs)
    height = abs(y2_abs - y1_abs)
    center_x = left + width / 2
    center_y = top + height / 2

    obj = _base_object(eid, "line")
    obj.update({
        "left": left,
        "top": top,
        "width": width,
        "height": height,
        "x1": x1_abs - center_x,
        "y1": y1_abs - center_y,
        "x2": x2_abs - center_x,
        "y2": y2_abs - center_y,
        "fill": "transparent",
        "stroke": el.get("stroke", "black"),
        "strokeWidth": el.get("stroke_width", 1),
        "backgroundColor": "",
        "scaleX": 1,
        "scaleY": 1,
        "productNumber": 1,
        "shapeName": "line",
    })
    return obj


def _image_object(el: dict, eid: int) -> dict:
    """Fabric.js image element with optional embedded base64 PNG."""
    img_data = el.get("image_data", "")
    src = f"data:image/png;base64,{img_data}" if img_data else ""

    obj = _base_object(eid, "image")
    obj.update({
        "left": el["x"],
        "top": el["y"],
        "width": el["width"],
        "height": el["height"],
        "scaleX": 1,
        "scaleY": 1,
        "src": src,
        "crossOrigin": "",
        "filters": [],
        "resizeFilters": [],
        "fill": "rgb(0,0,0)",
        "stroke": None,
        "strokeWidth": 0,
        "backgroundColor": "",
        "productNumber": 1,
        "isLogo": True,
    })
    return obj


def _barcode_object(el: dict, eid: int) -> dict:
    from src.esl.xsl_builder import BARCODE_XSL_NAME  # local import avoids circular dep
    field  = el.get("field", "ITEM_ID")
    btype  = el.get("barcode_type", "code128")
    xsl_name = BARCODE_XSL_NAME.get(btype, btype)
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
        "barcodeType": btype,
        "barcodeDataLink": field,
        "barcodeXslTypeName": xsl_name,
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
        "barcodeHumanReadable": el.get("human_readable", "none"),
        "wideFactor": 4,
        "moduleWidthTextBoxValue": "0.1",
        "barcodeConfig": "0",
        "barcodeModuleSize": "4",
        "aztecType": "0",
        "aztecMargin": "0",
        "barcodealign": el.get("barcode_align", "left"),
        "barcodeHRFontSize": 12,
        "barcodeDataTrimLength": 0,
        "barcodeDataTrimPosition": "start",
        "objects": [],  # inner text/image children omitted (designer re-generates)
    })
    return obj


def build_fabric_json(layout: dict, template_name: str = "AI_GENERATED", color_type: str = "4_COLOR") -> str:
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
        elif etype in ("rect", "rounded_rect"):
            objects.append(_rect_object(el, eid))
        elif etype == "circle":
            objects.append(_circle_object(el, eid))
        elif etype == "line":
            objects.append(_line_object(el, eid))
        elif etype == "image":
            objects.append(_image_object(el, eid))
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
            "layoutColor": color_type,
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
