#!/bin/bash

# Script para preparar la configuración nativa de iOS para Xcode en Fixture Mundial 2026

echo "================================================================="
# Hex color codes for formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0;0m' # No Color

echo -e "${BLUE}⚽ PREPARADOR DE ENTORNO IOS - FIXTURE MUNDIAL 2026${NC}"
echo "================================================================="

# 1. Check if flutter command is in PATH
if ! command -v flutter &> /dev/null
then
    echo -e "${YELLOW}⚠️ El comando 'flutter' no está disponible en tu PATH actual.${NC}"
    echo -e "Para preparar la carpeta de iOS y generar los archivos de Xcode, por favor asegúrate de:"
    echo -e " 1. Tener instalado el SDK de Flutter en tu Mac."
    echo -e " 2. Agregar Flutter a tu PATH (ej. export PATH=\$PATH:/tu-ruta-a-flutter/bin)."
    echo ""
    echo -e "Si ya lo tienes instalado, puedes ejecutar manualmente este comando en tu terminal principal:"
    echo -e " ${GREEN}flutter create --platforms=ios .${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Se detectó el SDK de Flutter en tu sistema.${NC}"
echo "Generando los archivos nativos de iOS..."

# 2. Run flutter create to generate ios folder
flutter create --platforms=ios .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=================================================================${NC}"
    echo -e "${GREEN}🎉 ¡CONFIGURACIÓN DE IOS CREADA CON ÉXITO!${NC}"
    echo -e "${GREEN}=================================================================${NC}"
    echo -e "Se han generado las carpetas y archivos nativos bajo el directorio ${BLUE}ios/${NC}:"
    echo -e " - ${BLUE}ios/Runner.xcodeproj${NC} (Proyecto Xcode)"
    echo -e " - ${BLUE}ios/Runner.xcworkspace${NC} (Espacio de trabajo recomendado)"
    echo ""
    echo -e "${YELLOW}👉 PASOS SIGUIENTES PARA PROBAR EN TU IPHONE FÍSICO:${NC}"
    echo -e " 1. Conecta tu iPhone al Mac mediante cable USB."
    echo -e " 2. Abre Xcode y haz clic en ${GREEN}File > Open...${NC} y selecciona la carpeta ${BLUE}ios/Runner.xcworkspace${NC}."
    echo -e " 3. En la barra lateral izquierda, selecciona el proyecto raíz ${BLUE}Runner${NC}."
    echo -e " 4. Dirígete a la pestaña ${GREEN}Signing & Capabilities${NC}."
    echo -e " 5. Activa ${GREEN}Automatically manage signing${NC} y selecciona tu ${GREEN}Team${NC} (cuenta de desarrollador gratuita)."
    echo -e " 6. Cambia el ${GREEN}Bundle Identifier${NC} a algo único si da error (ej. com.ariel.fixture2026)."
    echo -e " 7. En la barra superior de Xcode, selecciona tu ${BLUE}iPhone físico${NC} como destino de ejecución."
    echo -e " 8. Presiona el botón ${GREEN}Play (Run)${NC}."
    echo ""
    echo -e "${YELLOW}Nota en el iPhone:${NC} La primera vez, ve en tu iPhone a ${GREEN}Ajustes > General > VPN y gestión de dispositivos${NC} y dale a 'Confiar' en tu cuenta de desarrollador."
else
    echo -e "${RED}❌ Ocurrió un error al generar los archivos de iOS.${NC}"
fi
