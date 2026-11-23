USE DB_T05429_BEATRIZ_NATHAN;  # Seleciona o banco de dados onde estão as tabelas do Bar do Zé


-- 1. FATURAMENTO DO MÊS ATUAL
 -- Quanto o bar vendeu no total em março/2026 (último mês com dados). Leva em conta tantos vendas pagas e fiadas
--  ============================================================
SELECT SUM(QUANTITY * UNIT_PRICE) AS FATURAMENTO   -- Cada linha de venda vale quantidade x preço unitário; o SUM vai soma todas as linhas
FROM SALES                                         -- Tabela que registra cada venda
WHERE SALE_DATE BETWEEN '2026-11-01' AND '2026-11-30';  --  Filtra só as vendas de março (os dois limites são incluídos)

 -- 2. LUCRO DO ÚLTIMO MÊS
-- quanto sobrou em março depois de descontar
-- Lucro de uma venda = quantidade x (preço de venda - custo).
-- ============================================================
SELECT SUM(QUANTITY * (UNIT_PRICE - UNIT_COST)) AS LUCRO  -- qtd * preço de venda - custo e chamamos de lucro
FROM SALES                                                # Usa o preço e o custo gravados na venda (o histórico), não os atuais do produto(caso tenha alteração)
WHERE SALE_DATE BETWEEN '2026-03-01' AND '2026-03-31';    # Só março

 -- 3. LUCRO DOS ÚLTIMOS 3 MESES
-- mesmo cálculo da consulta 2, mas somando
-- janeiro, fevereiro e março (todo o período dos dados).
-- ============================================================
SELECT SUM(QUANTITY * (UNIT_PRICE - UNIT_COST)) AS LUCRO
FROM SALES
WHERE SALE_DATE BETWEEN '2026-01-01' AND '2026-03-31';    # Janela de 3 meses, de 01/01 até 31/0

-- 4. PRODUTO MAIS VENDIDO
-- Qual produto saiu em maior quantidade de unidades (não em dinheiro).
-- ============================================================
SELECT PRODUCT_NAME,                          -- Nome do produto na tabela PRODUCTS
       SUM(QUANTITY) AS TOTAL_VENDIDO         -- Soma as unidades vendidas de cada produto e chamamos de TOTAL_VENDIDO
FROM SALES                                    -- Buscamos da tabela SALESs
JOIN PRODUCTS USING (ID_PRODUCT)              -- Liga cada venda ao seu produto pela coluna em comum ID_PRODUCT
GROUP BY PRODUCT_NAME                         -- Junta todas as vendas do mesmo produto em uma linha só
ORDER BY TOTAL_VENDIDO DESC                   -- Ordena do maior total para o menor
LIMIT 1;                                      -- Mantém só a primeira linha, ou seja, o mais vendido

-- 5. PRODUTO MENOS VENDIDO
-- O mesmo da consulta 4. Mesmo código, só vamos mudar a ordem. 
-- ===============================================================
SELECT PRODUCT_NAME,
       SUM(QUANTITY) AS TOTAL_VENDIDO
FROM SALES
JOIN PRODUCTS USING (ID_PRODUCT)
GROUP BY PRODUCT_NAME
ORDER BY TOTAL_VENDIDO ASC                    -- ASC = do menor para o maior, então o primeiro é o menos vendido
LIMIT 1;

-- 6. FUNCIONÁRIO QUE MAIS VENDEU
-- Funcionario que gerou mais dinheiro em vendas. Medimos em valor (R$) e não em quantidade.
-- ============================================================
SELECT EMPLOYEE_NAME,                                   -- Nome do funcionário, que está na tabela EMPLOYEES
       SUM(QUANTITY * UNIT_PRICE) AS TOTAL_VENDIDO      -- Valor em R$ de tudo que ele vendeu, chamaremos de TOTAL_VENDIDO
FROM SALES
JOIN EMPLOYEES USING (ID_EMPLOYEE)                      -- Liga cada venda ao funcionário que a realizou
GROUP BY EMPLOYEE_NAME                                  -- Uma linha por funcionário
ORDER BY TOTAL_VENDIDO DESC                             -- Maior valor primeiro
LIMIT 1;                                                -- Só o que mais vendeu

-- 7. FUNCIONÁRIO QUE MENOS VENDEU
-- O mesmo da consulta 7, só vamos mudar de DESC para ASC(ordem crescente).
-- ============================================================
SELECT EMPLOYEE_NAME,
       SUM(QUANTITY * UNIT_PRICE) AS TOTAL_VENDIDO
FROM SALES
JOIN EMPLOYEES USING (ID_EMPLOYEE)
GROUP BY EMPLOYEE_NAME
ORDER BY TOTAL_VENDIDO ASC                              -- Do menor para o maior valor
LIMIT 1;

-- 8. PRODUTO COM MAIOR LUCRO
-- Localizar o produto que mais fez entrar dinheiro no caixa depois de descontar o custo (diferente de "mais vendido").
-- SALES e PRODUCTS têm colunas UNIT_COST. Por isso usamos SALES. na frente para identificar que estamos buscando da SALES
-- ============================================================
SELECT PRODUCT_NAME,
       SUM(QUANTITY * (SALES.UNIT_PRICE - SALES.UNIT_COST)) AS LUCRO   -- Lucro de cada venda, somado por produto
FROM SALES
JOIN PRODUCTS USING (ID_PRODUCT)
GROUP BY PRODUCT_NAME
ORDER BY LUCRO DESC                                     -- Maior lucro primeiro
LIMIT 1;


-- 9. PRODUTO COM MENOR LUCRO
-- O contrário da consulta 8 (ordem crescente).
-- ============================================================
SELECT PRODUCT_NAME,
       SUM(QUANTITY * (SALES.UNIT_PRICE - SALES.UNIT_COST)) AS LUCRO
FROM SALES
JOIN PRODUCTS USING (ID_PRODUCT)
GROUP BY PRODUCT_NAME
ORDER BY LUCRO ASC                                      -- Menor lucro primeiro
LIMIT 1;

-- 10. TOTAL DE VENDAS POR DIA
-- Ver quanto o bar vendeu em cada dia, para identificar os dias fortes e os fracos.
-- ============================================================
SELECT SALE_DATE,                                       -- Data da venda
       SUM(QUANTITY * UNIT_PRICE) AS TOTAL_DO_DIA       -- Soma o valor de todas as vendas daquela data
FROM SALES
GROUP BY SALE_DATE                                      -- Uma linha por dia
ORDER BY SALE_DATE;                                     -- Ordem cronológica, do primeiro ao último dia

-- 11. CLIENTE QUE MAIS COMPROU
-- Achar o melhor cliente em valor gasto. (Utilizando o JOIN, vamos desconsiderar as vendas sem cliente)
-- ============================================================
SELECT CUSTOMER_NAME,                                   -- Nome do cliente, que está na tabela CUSTOMERS
       SUM(QUANTITY * UNIT_PRICE) AS TOTAL_COMPRADO     -- Valor total que ele comprou (pago + fiado)
FROM SALES
JOIN CUSTOMERS USING (ID_CUSTOMER)                      -- Só entram vendas que têm cliente identificado
GROUP BY CUSTOMER_NAME
ORDER BY TOTAL_COMPRADO DESC
LIMIT 1;

-- 12. MARGEM DE LUCRO POR PRODUTO
-- Vamos ajudar o Zé a ganhar mais. Mostra quanto de cada R$ 100 vendidos fica de lucro em cada produto. Assim ele vê quais produtos vale a pena incentivar (margem alta) e quais
-- precisam de reajuste de preço (margem baixa, como o cigarro). Vamos fazer o seguinte calculo: (preço de venda - custo) / preço de venda x 100.
-- ============================================================
SELECT PRODUCT_NAME,
       ROUND((SALE_PRICE - UNIT_COST) / SALE_PRICE * 100, 1) AS MARGEM_PERCENTUAL  -- ROUND(...,1) limita a 1 casa decimal
FROM PRODUCTS                                           -- Não precisa de JOIN: preço e custo estão na própria tabela de produtos
ORDER BY MARGEM_PERCENTUAL DESC;                        # Da maior margem para a menor

-- 13.ENTRADAS E SAÍDAS POR MÊS
# Objetivo: dar ao Zé uma visão geral do caixa. Compara o que
# entrou de dinheiro com o que saiu (aluguel, luz, água) em cada
# mês, mostrando em quais meses o bar fechou no vermelho
# (janeiro e fevereiro só têm saídas, pois as vendas pagas
# começam em março).
# ============================================================
SELECT DATE_FORMAT(TRANSACTION_DATE, '%Y-%m') AS MES,   # Converte a data completa em ano-mês (ex.: 2026-03) para agrupar por mês
       TRANSACTION_TYPE,                                # ENTRADA (dinheiro que entrou) ou SAIDA (despesa)
       SUM(AMOUNT) AS TOTAL                             # Soma dos valores de cada tipo em cada mês
FROM FINANCIAL_TRANSACTIONS
GROUP BY MES, TRANSACTION_TYPE                          # Uma linha para cada combinação de mês e tipo
ORDER BY MES, TRANSACTION_TYPE;                         # Ordena por mês e, dentro do mês, por tipo

# 14. CLIENTE QUE MAIS COMPROU FIADO
 -- identificar o maior devedor do bar saber de quem cobrar primeiro e quem merece mais cautela.
-- ============================================================
SELECT CUSTOMER_NAME,
       SUM(QUANTITY * UNIT_PRICE) AS TOTAL_FIADO        -- Valor total que o cliente deve
FROM SALES
JOIN CUSTOMERS USING (ID_CUSTOMER)
WHERE PAYMENT_STATUS = 'FIADO'                          -- Considera só as vendas não pagas na hora
GROUP BY CUSTOMER_NAME
ORDER BY TOTAL_FIADO DESC
LIMIT 1;

-- 15. PRODUTO MAIS LEVADO SEM PAGAR NA HORA
-- Localizar qual produto os clientes mais pedem fiado, em unidades. Ajuda a decidir se vale restringir o fiado de algum produto.
-- ============================================================
SELECT PRODUCT_NAME,
       SUM(QUANTITY) AS QTD_FIADO                       -- Total de unidades levadas fiado
FROM SALES
JOIN PRODUCTS USING (ID_PRODUCT)
WHERE PAYMENT_STATUS = 'FIADO'                          -- Só vendas fiadas
GROUP BY PRODUCT_NAME
ORDER BY QTD_FIADO DESC
LIMIT 1;


-- ============================================================
-- 16. QUANTO O BAR DEIXOU DE ARRECADAR POR MÊS - JAN-FEV-MAR
-- Mostrar o dinheiro que deixou de receber por mês. Todo valor fiado é uma venda feita, mas cujo dinheiro ainda não entrou no caixa.
-- ============================================================
SELECT DATE_FORMAT(SALE_DATE, '%Y-%m') AS MES,           -- Ano-mês da venda
       SUM(QUANTITY * UNIT_PRICE) AS DEIXOU_DE_ARRECADAR  -- Soma do que foi vendido e não pago
FROM SALES
WHERE PAYMENT_STATUS = 'FIADO'                          -- Só vendas fiadas
GROUP BY MES                                            -- Uma linha por mês
ORDER BY MES;                                           -- Ordem cronológica

