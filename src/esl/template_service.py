"""
src/esl/template_service.py
----------------------------
Orchestrates the full ESL template generation pipeline:
  1. Call AI to get layout spec from natural language
  2. Build XSL from layout spec
  3. Build Fabric.js JSON from layout spec
"""

import json
from src.esl.generator import ESLGenerator, ESL_SIZES, DEFAULT_SIZE
from src.esl.xsl_builder import build_xsl
from src.esl.fabric_json_builder import build_fabric_json


class ESLTemplateService:
    def __init__(self):
        self._generators: dict[str, ESLGenerator] = {}

    def _get_generator(self, provider: str) -> ESLGenerator:
        if provider not in self._generators:
            self._generators[provider] = ESLGenerator(llm_provider=provider)
        return self._generators[provider]

    def generate(
        self,
        fields_json: str,
        description: str,
        size_key: str = DEFAULT_SIZE,
        provider: str = "anthropic",
    ) -> tuple[str, str, str]:
        """
        Full pipeline: natural language → XSL + Fabric JSON.

        Args:
            fields_json: JSON string of product fields, e.g.
                         '{"ITEM_NAME": "string", "LIST_PRICE": "decimal"}'
            description: natural language layout description
            size_key:    ESL size key from ESL_SIZES
            provider:    LLM provider name

        Returns:
            (xsl_content, fabric_json_content, layout_spec_json)
            All three are strings. Raises on error.
        """
        # Parse and validate fields
        try:
            fields = json.loads(fields_json)
            if not isinstance(fields, dict):
                raise ValueError("Fields must be a JSON object")
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid fields JSON: {e}") from e

        # Step 1: AI generates layout spec
        generator = self._get_generator(provider)
        layout_spec = generator.generate(fields, description, size_key)

        # Step 2: Build XSL
        xsl_content = build_xsl(layout_spec)

        # Step 3: Build Fabric.js JSON
        size_label = size_key.split("(")[0].strip().replace('"', '').replace(' ', '_')
        template_name = f"AI_{size_label}"
        fabric_json = build_fabric_json(layout_spec, template_name=template_name)

        layout_spec_str = json.dumps(layout_spec, indent=2)

        return xsl_content, fabric_json, layout_spec_str


# Module-level singleton
_service: ESLTemplateService | None = None

def get_service() -> ESLTemplateService:
    global _service
    if _service is None:
        _service = ESLTemplateService()
    return _service
