#!/bin/bash
# build.sh - Script para recriar a imagem do Buildroot para RISC-V

set -e  

# 1. Defina os caminhos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"  
BUILDROOT_SRC="$REPO_ROOT/third-party/buildroot-2025.02.19"
OUTPUT_DIR="$REPO_ROOT/build-limpo" 
DEFCONFIG_PATH="$REPO_ROOT/etapa2-buildroot/configs/custom_config"

echo "Carregando configuração..."
make -C "$BUILDROOT_SRC" O="$OUTPUT_DIR" BR2_DEFCONFIG="$DEFCONFIG_PATH" defconfig

echo "Iniciando build (isso pode demorar)..."
make -C "$BUILDROOT_SRC" O="$OUTPUT_DIR" -j$(nproc)

echo "Build concluído! Imagens em: $OUTPUT_DIR/images/"