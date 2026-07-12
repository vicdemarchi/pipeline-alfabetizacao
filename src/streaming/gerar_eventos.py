import json
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path


def carregar_municipios(arquivo: str = "municipios.txt") -> list[str]:
    municipios = [
        linha.strip()
        for linha in Path(arquivo).read_text(encoding="utf-8").splitlines()
        if linha.strip()
    ]

    if len(municipios) != 5:
        raise RuntimeError(
            f"Esperados 5 municípios, mas foram encontrados {len(municipios)}."
        )

    return municipios


def gerar_eventos() -> None:
    municipios = carregar_municipios()
    taxas_simuladas = [70.2, 71.4, 69.8, 74.1, 72.7]

    with open("eventos_streaming.jsonl", "w", encoding="utf-8") as arquivo:
        for id_municipio, taxa in zip(municipios, taxas_simuladas):
            agora = datetime.now(timezone.utc).isoformat()

            evento = {
                "event_id": str(uuid.uuid4()),
                "id_municipio": id_municipio,
                "ano": 2026,
                "taxa_alfabetizacao": taxa,
                "tipo_evento": "ATUALIZACAO_INDICADOR",
                "data_evento": agora,
                "data_ingestao": agora,
                "dado_simulado": True,
                "origem": "simulador_python_cloud_shell",
            }

            arquivo.write(json.dumps(evento, ensure_ascii=False) + "\n")
            print(json.dumps(evento, ensure_ascii=False))
            time.sleep(1)

    print("\nArquivo eventos_streaming.jsonl criado com sucesso.")


if __name__ == "__main__":
    gerar_eventos()
