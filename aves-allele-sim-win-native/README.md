# aves-allele-sim-win-native

Pipeline Windows-nativo (Windows 11, sem WSL e sem Docker) para preparar VCF, anotar variantes em **Gallus gallus** via **Ensembl VEP REST API**, (opcionalmente) intersectar com regiões regulatórias e gerar TSVs + um relatório em Markdown.

## Requisitos

- Windows 11
- Python **3.11+** (recomendado: **3.12**)
  - Instale pelo site oficial do Python (python.org) ou via Microsoft Store.
  - Se possível, habilite “Add Python to PATH”.
  - Observação: dependendo da versão, o pacote `pysam` pode não ter wheel disponível e o pip tentará compilar (não suportado aqui). Se isso acontecer, use Python 3.12 (ou 3.11) do python.org.

## Como rodar (um comando)

No **Prompt de Comando** (CMD), dentro da pasta do projeto:

```bat
run.cmd --config config.yaml
```

Também funciona no PowerShell (opcional):

```powershell
powershell -ExecutionPolicy Bypass -File .\\run.ps1 --config config.yaml
```

## Onde colocar os VCFs

Coloque seus arquivos `*.vcf.gz` em:

- `data\\vcf\\`

Exemplo:

- `data\\vcf\\meu_lote.vcf.gz`

Se não houver nenhum `*.vcf.gz` em `data\\vcf\\`, o pipeline vai parar e explicar o que fazer.

## Exemplos

Executar tudo (prepare → anotar → (opcional) intersect → relatório):

```bat
run.cmd --config config.yaml
```

Rodar só o preparo do VCF:

```bat
run.cmd --prepare-only
```

Rodar só a anotação (requer `work\\prepared\\prepared.vcf.gz`):

```bat
run.cmd --annotate-only
```

## Saídas

- `work\\prepared\\prepared.vcf.gz` (+ `prepared.vcf.gz.tbi`)
- `results\\variants_gene_consequence.tsv`
- `results\\REPORT.md`
- `results\\variants_regulatory.tsv` (somente se a interseção regulatória rodar)

Logs:

- `work\\logs\\prepare.log`
- `work\\logs\\vep.log`
- `work\\logs\\intersect.log`
- `work\\logs\\report.log`

## Interseção com regiões regulatórias (opcional)

1) Coloque um arquivo BED ou GFF3 em `data\\regulatory\\`.
2) Ajuste no `config.yaml`:

- `do_regulatory_intersect: true`
- `regulatory_file: data/regulatory/SEU_ARQUIVO.bed` (ou `.gff3`)

## Notas sobre VEP REST e cache

- As chamadas à Ensembl REST API têm limites de taxa; o pipeline aplica `rest_sleep_ms` e retry exponencial.
- Existe cache local por variante em `work\\cache\\vep\\` para evitar reconsultas.

## Solução de problemas

### Erro ao instalar `pysam` (wheel não encontrado)

Se aparecer algo como:

- `No matching distribution found for pysam`

Faça:

1) Instale Python **3.12** (ou 3.11) pelo python.org
2) Apague a pasta `.\.venv\` dentro do projeto (para recriar com a versão correta)
3) Rode `run.cmd` novamente
