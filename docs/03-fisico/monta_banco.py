"""
monta_banco.py - utilitário do Projeto A3 (Controle de Estacionamento)

Uso:
    python monta_banco.py              -> executa a QUERY abaixo (modo livre)
    python monta_banco.py --montar     -> recria o banco do zero (00 -> 01 -> 02)
    python monta_banco.py --consultas  -> executa sql/03-consultas.sql
    python monta_banco.py --arquivo X  -> executa um arquivo .sql qualquer
"""

from pathlib import Path
import sqlite3
import sys

# Caminhos: o .db fica ao lado deste script; os .sql ficam em <repo>/sql
BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "estacionamento_sql.db"
SQL_DIR = BASE_DIR.parents[1] / "sql"

# Ordem obrigatória de execução (a base fornecida SEMPRE primeiro)
SCRIPTS_MONTAGEM = [
    "00-base-fornecida.sql",
    "01-schema.sql",
    "02-dados.sql",
]

# =====================================================================
# ÁREA DA QUERY: Escreva aqui suas instruções SQL (com quebras de linha)
# =====================================================================
QUERY = """
SELECT * FROM Tarifa AS t1;
"""


def dividir_comandos(sql: str) -> list[str]:
    """Divide o SQL em comandos completos.

    Usa sqlite3.complete_statement, então ';' dentro de strings ou
    comentários NÃO quebra o comando (o split simples por ';' quebrava).
    """
    comandos, buffer = [], ""
    for parte in sql.split(";"):
        buffer += parte + ";"
        if sqlite3.complete_statement(buffer):
            # ignora pedaços que só têm comentários/espaços
            util = "\n".join(
                linha for linha in buffer.splitlines()
                if not linha.strip().startswith("--")
            ).strip(" \t\r\n;")
            if util:
                comandos.append(buffer.strip())
            buffer = ""
    return comandos


def _imprimir_resultado(cursor: sqlite3.Cursor, i: int) -> None:
    colunas = [desc[0] for desc in cursor.description]
    linhas = cursor.fetchall()
    cabecalho = " | ".join(colunas)
    print(f"\n--- Resultado (Comando #{i}) ---")
    print(cabecalho)
    print("-" * (len(cabecalho) + 10))
    if not linhas:
        print("(Nenhum registro encontrado)")
    for linha in linhas:
        print(" | ".join(str(valor) for valor in linha))


def executar_sql(conn: sqlite3.Connection, sql: str, verboso: bool = True) -> bool:
    """Executa todos os comandos em UMA transação. Em erro, faz ROLLBACK de tudo."""
    cursor = conn.cursor()
    comandos = dividir_comandos(sql)
    i, comando = 0, "BEGIN;"
    try:
        cursor.execute("BEGIN;")
        for i, comando in enumerate(comandos, start=1):
            cursor.execute(comando)
            if cursor.description is not None:          # SELECT / PRAGMA / RETURNING
                _imprimir_resultado(cursor, i)
            elif verboso:                                # CREATE / INSERT / DROP ...
                afetadas = cursor.rowcount
                extra = f" ({afetadas} linhas afetadas)" if afetadas >= 0 else ""
                print(f"[OK] Comando #{i} executado com sucesso{extra}.")
        cursor.execute("COMMIT;")
        return True
    except sqlite3.Error as erro:
        if conn.in_transaction:
            cursor.execute("ROLLBACK;")
        print(f"\n[ERRO SQLite] no comando #{i}: {erro}\n{comando[:300]}")
        return False


def conectar(caminho_db: Path = DB_PATH) -> sqlite3.Connection:
    # isolation_level=None -> nós controlamos BEGIN/COMMIT/ROLLBACK manualmente
    conn = sqlite3.connect(caminho_db, isolation_level=None)
    # Precisa ser executado FORA de transação (dentro dela o PRAGMA é ignorado)
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn


def executar_arquivo(conn: sqlite3.Connection, arquivo: Path, verboso: bool = False) -> bool:
    print(f"\n>>> Executando {arquivo.name}")
    ok = executar_sql(conn, arquivo.read_text(encoding="utf-8"), verboso)
    print(f"<<< {arquivo.name}: {'OK' if ok else 'FALHOU (rollback aplicado)'}")
    return ok


def montar_banco() -> bool:
    """Recria o banco do zero, na ordem 00 -> 01 -> 02.

    O arquivo .db é apagado antes: assim o DROP de marca/modelo do script 00
    nunca esbarra em chaves estrangeiras de Veiculo de uma execução anterior.
    """
    DB_PATH.unlink(missing_ok=True)
    conn = conectar()
    try:
        for nome in SCRIPTS_MONTAGEM:
            if not executar_arquivo(conn, SQL_DIR / nome):
                return False
        # Verificação final de integridade referencial
        violacoes = conn.execute("PRAGMA foreign_key_check;").fetchall()
        print(f"\nPRAGMA foreign_key_check: {'OK' if not violacoes else violacoes}")
        return not violacoes
    finally:
        conn.close()


if __name__ == "__main__":
    print(f"Banco: {DB_PATH}")
    args = sys.argv[1:]
    if args and args[0] == "--montar":
        sys.exit(0 if montar_banco() else 1)

    conexao = conectar()
    try:
        if args and args[0] == "--consultas":
            executar_arquivo(conexao, SQL_DIR / "03-consultas.sql")
        elif len(args) == 2 and args[0] == "--arquivo":
            executar_arquivo(conexao, Path(args[1]), verboso=True)
        else:
            executar_sql(conexao, QUERY)
    finally:
        conexao.close()
