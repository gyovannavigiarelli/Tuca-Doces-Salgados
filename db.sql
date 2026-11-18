-- ============================================================================
-- BANCO DE DADOS: TUCA DOCES & SALGADOS (FASE 4 - MODELAGEM E CONSTRAINTS)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS tuca_doces_salgados
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE tuca_doces_salgados;

-- 1. TABELA CLIENTES
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome_completo VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL,
    telefone VARCHAR(20) NULL,
    aceite_cookies BOOLEAN NOT NULL DEFAULT FALSE,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_clientes_email UNIQUE (email),
    CONSTRAINT chk_clientes_email CHECK (email LIKE '%_@__%.__%')
);

-- 2. TABELA CATEGORIAS
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(60) NOT NULL,
    descricao VARCHAR(255) NULL,
    CONSTRAINT uq_categorias_nome UNIQUE (nome_categoria)
);

-- 3. TABELA PRODUTOS
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_produto VARCHAR(100) NOT NULL,
    descricao TEXT NULL,
    preco_base DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    unidade_medida VARCHAR(20) NOT NULL DEFAULT 'UNIDADE',
    url_imagem VARCHAR(500) NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_produtos_nome UNIQUE (nome_produto),
    CONSTRAINT fk_produtos_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_produtos_preco CHECK (preco_base >= 0),
    CONSTRAINT chk_produtos_unidade CHECK (unidade_medida IN ('KG', 'CENTO', 'UNIDADE'))
);

-- 4. TABELA PEDIDOS
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_evento DATE NOT NULL,
    horario_entrega TIME NULL DEFAULT '14:00:00',
    tipo_entrega VARCHAR(20) NOT NULL DEFAULT 'RETIRADA',
    taxa_entrega DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    valor_total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status_pedido VARCHAR(30) NOT NULL DEFAULT 'ORCAMENTO',
    detalhes_pedido TEXT NULL,
    CONSTRAINT fk_pedidos_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_pedidos_horario CHECK (horario_entrega BETWEEN '09:00:00' AND '18:00:00'),
    CONSTRAINT chk_pedidos_tipo_entrega CHECK (tipo_entrega IN ('RETIRADA', 'DELIVERY')),
    CONSTRAINT chk_pedidos_taxa CHECK (taxa_entrega >= 0),
    CONSTRAINT chk_pedidos_total CHECK (valor_total >= 0),
    CONSTRAINT chk_pedidos_status CHECK (
        status_pedido IN ('ORCAMENTO', 'AGUARDANDO_SINAL', 'CONFIRMADO', 'ENTREGUE', 'CANCELADO')
    )
);

-- 5. TABELA ASSOCIATIVA ITENS_PEDIDO (N:N entre PEDIDOS e PRODUTOS)
CREATE TABLE itens_pedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade DECIMAL(6, 2) NOT NULL DEFAULT 1.00,
    sabor_recheio VARCHAR(100) NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_itens_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedidos (id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_itens_produto FOREIGN KEY (id_produto)
        REFERENCES produtos (id_produto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_itens_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_itens_preco CHECK (preco_unitario >= 0)
);

-- 6. TABELA PAGAMENTOS (Regra de Sinal 50% Pix + 50% Entrega)
CREATE TABLE pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    tipo_parcela VARCHAR(20) NOT NULL DEFAULT 'SINAL_50',
    forma_pagamento VARCHAR(20) NOT NULL DEFAULT 'PIX',
    valor_pago DECIMAL(10, 2) NOT NULL,
    status_pagamento VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    data_pagamento DATETIME NULL,
    CONSTRAINT fk_pagamentos_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedidos (id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT chk_pagamentos_parcela CHECK (tipo_parcela IN ('SINAL_50', 'RESTANTE_50', 'INTEGRAL')),
    CONSTRAINT chk_pagamentos_forma CHECK (forma_pagamento IN ('PIX', 'CARTAO')),
    CONSTRAINT chk_pagamentos_valor CHECK (valor_pago > 0),
    CONSTRAINT chk_pagamentos_status CHECK (status_pagamento IN ('PENDENTE', 'PAGO', 'RETIDO'))
);

-- ============================================================================
-- CARGA INICIAL DE DADOS (ALINHADA COM O SITE E O CHATBOT)
-- ============================================================================

INSERT INTO categorias (nome_categoria, descricao) VALUES
('Bolos Festivos', 'Bolos fofinhos e personalizados com recheios cremosos e acabamento impecável.'),
('Doces Finos', 'Brigadeiros gourmet, beijinhos e opções refinadas para eventos.'),
('Salgadinhos', 'Coxinhas crocantes, empadinhas, assados e fritos preparados no dia.'),
('Tortas Especiais', 'Tortas geladas e artesanais com frutas frescas e cremes suaves.');

INSERT INTO produtos (id_categoria, nome_produto, descricao, preco_base, unidade_medida, url_imagem) VALUES
(4, 'Torta Especial de Morango', 'Massa leve e crocante recheada com creme patissier suave, coberta com morangos frescos selecionados.', 85.00, 'UNIDADE', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1WvDCJ3aikwll-dukWz9g9tY8_V9x9oWsXOtjwxSiXtKNQpicTEu6SF0&s=10'),
(4, 'Torta Holandesa Cremosa', 'Clássico creme holandês feito com nata e leite condensado, base de biscoito e ganache meio amargo.', 90.00, 'UNIDADE', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=80'),
(1, 'Bolo de Festa Personalizado', 'Massa pão de ló de chocolate extra macia com recheio duplo e cobertura de Chantininho.', 75.00, 'KG', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTU5MPp23nDsFR3aaH3mRDTY93fVX4cjA0NqiiXe5gSFtcd1ey6aBybChum&s=10'),
(3, 'Cento de Salgadinhos Variados', 'Coxinhas de frango com requeijão, bolinhas de queijo, kibe e empadinhas de palmito.', 95.00, 'CENTO', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEWOK3hYv5Zn3maXmTTirmRF2awO1SfYrkkdriDENfI6QOrYVNn85h5H8&s=10'),
(2, 'Cento de Doces Finos Gourmet', 'Brigadeiros gourmet (Ninho com Nutella, Belga) e beijinhos artesanais.', 110.00, 'CENTO', NULL);
