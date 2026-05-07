import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib as mpl

mpl.rcParams['font.family'] = 'DejaVu Sans'

NUM_WEEKS = 9

# Phase colors (header row) and bar colors
PHASE_COLORS = {
    1: ("#BDD7EE", "#2E74B5"),  # blue
    2: ("#C6EFCE", "#375623"),  # green
    3: ("#FFEB9C", "#9C5700"),  # yellow
    4: ("#FFC7CE", "#9C0006"),  # red/salmon
    5: ("#D9D2E9", "#4C1130"),  # violet
    6: ("#E1D5E7", "#6B2C91"),  # purple
}

data = [
    # (id, name, assignee, phase, start_week, end_week, is_phase_header)
    ("1", "Definição do Sistema", "", 1, 1, 2, True),
    ("1.1", "Contextualização", "André", 1, 1, 1, False),
    ("1.2", "Motivação e Objetivos", "Bruno", 1, 1, 1, False),
    ("1.3", "Análise de Viabilidade", "João", 1, 1, 2, False),
    ("1.4", "Recursos e Equipa", "Nelson", 1, 2, 2, False),
    ("1.5", "Plano de Execução", "Tiago", 1, 2, 2, False),

    ("2", "Levantamento de Requisitos", "", 2, 3, 3, True),
    ("2.1", "Método de Levantamento", "André", 2, 3, 3, False),
    ("2.2", "Organização de Requisitos", "Bruno, João", 2, 3, 3, False),
    ("2.3", "Validação de Requisitos", "Nelson, Tiago", 2, 3, 3, False),

    ("3", "Modelação Conceptual", "", 3, 4, 5, True),
    ("3.1", "Abordagem de Modelação", "André", 3, 4, 4, False),
    ("3.2", "Identificação de Entidades", "João", 3, 4, 4, False),
    ("3.3", "Identificação Relacionamentos", "Nelson", 3, 4, 5, False),
    ("3.4", "Atributos", "Tiago", 3, 5, 5, False),
    ("3.5", "Diagrama ER Final", "Bruno", 3, 5, 5, False),

    ("4", "Modelação Lógica", "", 4, 6, 6, True),
    ("4.1", "Construção Modelo Lógico", "André", 4, 6, 6, False),
    ("4.2", "Documentação do Modelo", "Bruno", 4, 6, 6, False),
    ("4.3", "Normalização", "João", 4, 6, 6, False),
    ("4.4", "Validação UCQs", "Nelson, Tiago", 4, 6, 6, False),

    ("5", "Implementação Física", "", 5, 7, 8, True),
    ("5.1", "Scripts DDL", "Tiago", 5, 7, 7, False),
    ("5.2", "Utilizadores e Privilégios", "Nelson", 5, 7, 7, False),
    ("5.3", "Povoamento da BD", "André", 5, 7, 7, False),
    ("5.4", "Cálculo de Espaço", "Bruno", 5, 7, 7, False),
    ("5.5", "Vistas SQL", "João", 5, 7, 8, False),
    ("5.6", "UCQs em SQL", "André", 5, 8, 8, False),
    ("5.7", "Indexação", "Nelson", 5, 8, 8, False),
    ("5.8", "Procedures/Triggers", "Tiago", 5, 8, 8, False),

    ("6", "Revisão e Entrega Final", "", 6, 9, 9, True),
    ("6.1", "Testes de Integridade", "Todos", 6, 9, 9, False),
    ("6.2", "Revisão Cruzada", "Todos", 6, 9, 9, False),
    ("6.3", "Redação Final", "Bruno", 6, 9, 9, False),
    ("6.4", "Submissão", "Todos", 6, 9, 9, False),
]

n_rows = len(data)
ROW_H = 0.55
HEADER_H = 0.65

# Column widths (relative)
COL_ID   = 0.5
COL_NAME = 3.8
COL_ASSIGN = 1.8
COL_FASE = 0.5
WEEK_W   = 0.75

total_w = COL_ID + COL_NAME + COL_ASSIGN + COL_FASE + NUM_WEEKS * WEEK_W
total_h = HEADER_H + n_rows * ROW_H

fig, ax = plt.subplots(figsize=(total_w * 0.55, total_h * 0.55))
ax.set_xlim(0, total_w)
ax.set_ylim(0, total_h)
ax.axis('off')

def col_x(col):
    positions = {
        'id':     0,
        'name':   COL_ID,
        'assign': COL_ID + COL_NAME,
        'fase':   COL_ID + COL_NAME + COL_ASSIGN,
        'week1':  COL_ID + COL_NAME + COL_ASSIGN + COL_FASE,
    }
    return positions[col]

def week_x(w):
    return col_x('week1') + (w - 1) * WEEK_W

# Draw header row
header_y = total_h - HEADER_H
header_cols = [
    (col_x('id'),     COL_ID,    "Id"),
    (col_x('name'),   COL_NAME,  "Tarefa"),
    (col_x('assign'), COL_ASSIGN,"Atribuído a:"),
    (col_x('fase'),   COL_FASE,  "Fase"),
]
for week in range(1, NUM_WEEKS + 1):
    header_cols.append((week_x(week), WEEK_W, f"S.{week}"))

for x, w, label in header_cols:
    rect = mpatches.FancyBboxPatch((x, header_y), w, HEADER_H,
        boxstyle="square,pad=0", linewidth=0.5,
        edgecolor='white', facecolor='#2E4057')
    ax.add_patch(rect)
    fs = 6.5 if label.startswith("S.") else 7
    ax.text(x + w/2, header_y + HEADER_H/2, label,
            ha='center', va='center', fontsize=fs,
            color='white', fontweight='bold')

# Draw data rows
for i, row in enumerate(data):
    rid, name, assignee, phase, s_week, e_week, is_header = row
    y = total_h - HEADER_H - (i + 1) * ROW_H
    bar_color, text_color_h = PHASE_COLORS[phase]
    row_bg = bar_color if is_header else ('white' if i % 2 == 0 else '#F5F5F5')

    # Background
    full_rect = mpatches.FancyBboxPatch((0, y), total_w, ROW_H,
        boxstyle="square,pad=0", linewidth=0.3,
        edgecolor='#CCCCCC', facecolor=row_bg)
    ax.add_patch(full_rect)

    # Id cell
    id_text_color = text_color_h if is_header else 'black'
    id_fw = 'bold' if is_header else 'normal'
    ax.text(col_x('id') + COL_ID/2, y + ROW_H/2, rid,
            ha='center', va='center', fontsize=7,
            color=id_text_color, fontweight=id_fw)

    # Name cell
    name_fw = 'bold' if is_header else 'normal'
    ax.text(col_x('name') + 0.1, y + ROW_H/2, name,
            ha='left', va='center', fontsize=7,
            color=id_text_color, fontweight=name_fw)

    # Assignee
    if not is_header:
        ax.text(col_x('assign') + 0.1, y + ROW_H/2, assignee,
                ha='left', va='center', fontsize=6.5, color='black')

    # Fase
    if not is_header:
        ax.text(col_x('fase') + COL_FASE/2, y + ROW_H/2, str(phase),
                ha='center', va='center', fontsize=6.5, color='black')
    else:
        ax.text(col_x('fase') + COL_FASE/2, y + ROW_H/2, "Fase",
                ha='center', va='center', fontsize=6.5,
                color=text_color_h, fontweight='bold')

    # Week bars
    for w in range(1, NUM_WEEKS + 1):
        wx = week_x(w)
        cell_bg = '#F5F5F5' if not is_header else row_bg
        # draw week cell border
        cell = mpatches.FancyBboxPatch((wx, y), WEEK_W, ROW_H,
            boxstyle="square,pad=0", linewidth=0.3,
            edgecolor='#CCCCCC', facecolor=cell_bg)
        ax.add_patch(cell)

        if s_week <= w <= e_week:
            pad = 0.06
            bar = mpatches.FancyBboxPatch(
                (wx + pad, y + pad), WEEK_W - 2*pad, ROW_H - 2*pad,
                boxstyle="round,pad=0.02", linewidth=0.5,
                edgecolor=text_color_h, facecolor=bar_color)
            ax.add_patch(bar)

# Outer border
outer = mpatches.FancyBboxPatch((0, 0), total_w, total_h,
    boxstyle="square,pad=0", linewidth=1,
    edgecolor='#555555', facecolor='none')
ax.add_patch(outer)

plt.tight_layout(pad=0)
plt.savefig('/home/tiago_santos/Projeto_BD/imagens/gantt.pdf',
            bbox_inches='tight', dpi=200, format='pdf')
plt.savefig('/home/tiago_santos/Projeto_BD/imagens/gantt.png',
            bbox_inches='tight', dpi=200)
print("Gerado com sucesso")
