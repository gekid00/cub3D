#!/bin/bash

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Compteurs
TOTAL=0
PASSED=0
FAILED=0

# Fonction pour tester une map
test_map() {
    local map=$1
    local should_pass=$2
    local description=$3
    
    TOTAL=$((TOTAL + 1))
    
    echo -e "\n${BLUE}Test $TOTAL: ${description}${NC}"
    echo -e "Map: ${map}"
    
    # Tester la map
    has_leak=0
    VALGRIND_OPTS="--leak-check=full --show-leak-kinds=all --track-origins=yes --track-fds=yes --error-exitcode=42"
    
    # Tester avec valgrind pour toutes les maps (valides et invalides)
    timeout 2 valgrind $VALGRIND_OPTS ./cub3D "$map" > /dev/null 2>&1
    exit_code=$?
    
    # Vérifier si leak détecté
    if [ $exit_code -eq 42 ]; then
        has_leak=1
    fi
    
    # Vérifier le résultat
    if [ "$should_pass" = "valid" ]; then
        if [ $exit_code -eq 0 ] || [ $exit_code -eq 124 ]; then
            if [ $has_leak -eq 1 ]; then
                echo -e "${YELLOW}✓ PASS (avec memory leak)${NC} - Map valide acceptée"
            else
                echo -e "${GREEN}✓ PASS${NC} - Map valide acceptée"
            fi
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}✗ FAIL${NC} - Map valide rejetée (exit code: $exit_code)"
            FAILED=$((FAILED + 1))
        fi
    else
        if [ $exit_code -ne 0 ] && [ $exit_code -ne 124 ] && [ $exit_code -ne 42 ]; then
            if [ $has_leak -eq 1 ]; then
                echo -e "${YELLOW}✓ PASS (avec memory leak)${NC} - Map invalide rejetée"
            else
                echo -e "${GREEN}✓ PASS${NC} - Map invalide rejetée"
            fi
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}✗ FAIL${NC} - Map invalide acceptée"
            FAILED=$((FAILED + 1))
        fi
    fi
}

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}    CUB3D MAPS_DUR TEST SUITE    ${NC}"
echo -e "${YELLOW}========================================${NC}"

echo -e "${YELLOW}Valgrind activé sur TOUTES les maps (détection memory leaks)${NC}"

# Vérifier que l'exécutable existe
if [ ! -f "./cub3D" ]; then
    echo -e "${RED}Erreur: ./cub3D n'existe pas${NC}"
    echo "Compilation en cours..."
    make
    if [ ! -f "./cub3D" ]; then
        echo -e "${RED}Erreur: Compilation échouée${NC}"
        exit 1
    fi
fi

# ============================================
# TESTS DE MAPS VALIDES
# ============================================
echo -e "\n${YELLOW}=== TESTS DE MAPS VALIDES ===${NC}"

test_map "maps_dur/valide/sqare.cub" "valid" "Map square"
test_map "maps_dur/valide/test.cub" "valid" "Map test"
test_map "maps_dur/valide/couloir.cub" "valid" "Map couloir"
test_map "maps_dur/valide/test_2.cub" "valid" "Map test_2 (lignes irrégulières)"
test_map "maps_dur/valide/test_3.cub" "valid" "Map test_3 (grande map irrégulière)"
test_map "maps_dur/valide/test_4.cub" "valid" "Map test_4 (map avec espaces)"

# ============================================
# TESTS DE BONUS (contiennent P - doors)
# ============================================
echo -e "\n${YELLOW}=== TESTS DE BONUS (avec portes P) ===${NC}"

test_map "maps_dur/bonus/couloir.cub" "invalid" "Bonus - Map couloir (contient P)"

# ============================================
# TESTS INVALIDES - ERREURS STRUCTURELLES
# ============================================
echo -e "\n${YELLOW}=== TESTS INVALIDES - STRUCTURE ===${NC}"

test_map "maps_dur/invalide/circle.cub" "invalid" "Map circle (lignes vides + 2 maps)"
test_map "maps_dur/invalide/test_5.cub" "invalid" "Map test_5 (map ouverte)"

# ============================================
# TESTS DE MAPS INVALIDES
# ============================================
echo -e "\n${YELLOW}=== TESTS DE MAPS INVALIDES ===${NC}"

test_map "maps_dur/invalide/double_ceilling_name.cub" "invalid" "Double déclaration ceiling"
test_map "maps_dur/invalide/double_texture_name.cub" "invalid" "Double déclaration texture"
test_map "maps_dur/invalide/no_player.cub" "invalid" "Pas de joueur"
test_map "maps_dur/invalide/wrong_ceiling_format.cub" "invalid" "Format ceiling invalide"
test_map "maps_dur/invalide/wrong_color_format.cub" "invalid" "Format couleur invalide"
test_map "maps_dur/invalide/wrong_floor.cub" "invalid" "Floor invalide"
test_map "maps_dur/invalide/wrong_map.cub" "invalid" "Map invalide"
test_map "maps_dur/invalide/wrong_texture_format.cub" "invalid" "Format texture invalide"
test_map "maps_dur/invalide/wrong_texture_place.cub" "invalid" "Texture mal placée"

# ============================================
# TESTS INVALIDES ANTHO - CONFIGURATION
# ============================================
echo -e "\n${YELLOW}=== TESTS INVALIDES ANTHO - CONFIGURATION ===${NC}"

test_map "maps_dur/invalide_antho/C_after_map.cub" "invalid" "C après la map"
test_map "maps_dur/invalide_antho/EA_after_map.cub" "invalid" "EA après la map"
test_map "maps_dur/invalide_antho/F_after_map.cub" "invalid" "F après la map"
test_map "maps_dur/invalide_antho/NO_after_map.cub" "invalid" "NO après la map"
test_map "maps_dur/invalide_antho/SO_after_map.cub" "invalid" "SO après la map"
test_map "maps_dur/invalide_antho/WE_after_map.cub" "invalid" "WE après la map"
test_map "maps_dur/invalide_antho/doube_WE.cub" "invalid" "Double WE"
test_map "maps_dur/invalide_antho/double_C.cub" "invalid" "Double C"
test_map "maps_dur/invalide_antho/double_EA.cub" "invalid" "Double EA"
test_map "maps_dur/invalide_antho/double_F.cub" "invalid" "Double F"
test_map "maps_dur/invalide_antho/double_NO.cub" "invalid" "Double NO"
test_map "maps_dur/invalide_antho/double_SO.cub" "invalid" "Double SO"

# ============================================
# TESTS INVALIDES ANTHO - COULEURS
# ============================================
echo -e "\n${YELLOW}=== TESTS INVALIDES ANTHO - COULEURS ===${NC}"

test_map "maps_dur/invalide_antho/extra_C_element.cub" "invalid" "Élément C supplémentaire"
test_map "maps_dur/invalide_antho/extra_F_element.cub" "invalid" "Élément F supplémentaire"
test_map "maps_dur/invalide_antho/missing_C.cub" "invalid" "C manquant"
test_map "maps_dur/invalide_antho/missing_C_blue.cub" "invalid" "C blue manquant"
test_map "maps_dur/invalide_antho/missing_C_green.cub" "invalid" "C green manquant"
test_map "maps_dur/invalide_antho/missing_C_red.cub" "invalid" "C red manquant"
test_map "maps_dur/invalide_antho/missing_C_rgb.cub" "invalid" "C rgb manquant"
test_map "maps_dur/invalide_antho/missing_F.cub" "invalid" "F manquant"
test_map "maps_dur/invalide_antho/missing_F_blue.cub" "invalid" "F blue manquant"
test_map "maps_dur/invalide_antho/missing_F_green.cub" "invalid" "F green manquant"
test_map "maps_dur/invalide_antho/missing_F_red.cub" "invalid" "F red manquant"
test_map "maps_dur/invalide_antho/missing_F_rgb.cub" "invalid" "F rgb manquant"
test_map "maps_dur/invalide_antho/negative_C_blue.cub" "invalid" "C blue négatif"
test_map "maps_dur/invalide_antho/negative_C_green.cub" "invalid" "C green négatif"
test_map "maps_dur/invalide_antho/negative_C_red.cub" "invalid" "C red négatif"
test_map "maps_dur/invalide_antho/negative_F_blue.cub" "invalid" "F blue négatif"
test_map "maps_dur/invalide_antho/negative_F_green.cub" "invalid" "F green négatif"
test_map "maps_dur/invalide_antho/negative_F_red.cub" "invalid" "F red négatif"
test_map "maps_dur/invalide_antho/too_large_C_blue.cub" "invalid" "C blue trop large"
test_map "maps_dur/invalide_antho/too_large_C_green.cub" "invalid" "C green trop large"
test_map "maps_dur/invalide_antho/too_large_C_red.cub" "invalid" "C red trop large"
test_map "maps_dur/invalide_antho/too_large_F_blue.cub" "invalid" "F blue trop large"
test_map "maps_dur/invalide_antho/too_large_F_green.cub" "invalid" "F green trop large"
test_map "maps_dur/invalide_antho/too_large_F_red.cub" "invalid" "F red trop large"
test_map "maps_dur/invalide_antho/wrong_C_separator.cub" "invalid" "Séparateur C invalide"
test_map "maps_dur/invalide_antho/wrong_F_separator.cub" "invalid" "Séparateur F invalide"

# ============================================
# TESTS INVALIDES ANTHO - TEXTURES
# ============================================
echo -e "\n${YELLOW}=== TESTS INVALIDES ANTHO - TEXTURES ===${NC}"

test_map "maps_dur/invalide_antho/invalid_EA_texture.cub" "invalid" "Texture EA invalide"
test_map "maps_dur/invalide_antho/invalid_NO_texture.cub" "invalid" "Texture NO invalide"
test_map "maps_dur/invalide_antho/invalid_SO_texture.cub" "invalid" "Texture SO invalide"
test_map "maps_dur/invalide_antho/invalid_WE_texture.cub" "invalid" "Texture WE invalide"
test_map "maps_dur/invalide_antho/lowercase_EA.cub" "invalid" "EA en minuscule"
test_map "maps_dur/invalide_antho/lowercase_NO.cub" "invalid" "NO en minuscule"
test_map "maps_dur/invalide_antho/lowercase_SO.cub" "invalid" "SO en minuscule"
test_map "maps_dur/invalide_antho/lowercase_WE.cub" "invalid" "WE en minuscule"
test_map "maps_dur/invalide_antho/missing_EA.cub" "invalid" "EA manquant"
test_map "maps_dur/invalide_antho/missing_EA_path.cub" "invalid" "Chemin EA manquant"
test_map "maps_dur/invalide_antho/missing_NO.cub" "invalid" "NO manquant"
test_map "maps_dur/invalide_antho/missing_NO_path.cub" "invalid" "Chemin NO manquant"
test_map "maps_dur/invalide_antho/missing_SO.cub" "invalid" "SO manquant"
test_map "maps_dur/invalide_antho/missing_SO_path.cub" "invalid" "Chemin SO manquant"
test_map "maps_dur/invalide_antho/missing_WE.cub" "invalid" "WE manquant"
test_map "maps_dur/invalide_antho/missing_WE_path.cub" "invalid" "Chemin WE manquant"
test_map "maps_dur/invalide_antho/no_read_perm_on_EA_texture.cub" "invalid" "EA sans permission lecture"
test_map "maps_dur/invalide_antho/no_read_perm_on_NO_texture.cub" "invalid" "NO sans permission lecture"
test_map "maps_dur/invalide_antho/no_read_perm_on_SO_texture.cub" "invalid" "SO sans permission lecture"
test_map "maps_dur/invalide_antho/no_read_perm_on_WE_texture.cub" "invalid" "WE sans permission lecture"
test_map "maps_dur/invalide_antho/wrong_EA_texture_ext.cub" "invalid" "Extension EA invalide"
test_map "maps_dur/invalide_antho/wrong_NO_texture_ext.cub" "invalid" "Extension NO invalide"
test_map "maps_dur/invalide_antho/wrong_SO_texture_ext.cub" "invalid" "Extension SO invalide"
test_map "maps_dur/invalide_antho/wrong_WE_texture_ext.cub" "invalid" "Extension WE invalide"

# ============================================
# TESTS INVALIDES ANTHO - MAP
# ============================================
echo -e "\n${YELLOW}=== TESTS INVALIDES ANTHO - MAP ===${NC}"

test_map "maps_dur/invalide_antho/map_has_no_player.cub" "invalid" "Map sans joueur"
test_map "maps_dur/invalide_antho/map_has_two_players.cub" "invalid" "Map avec deux joueurs"
test_map "maps_dur/invalide_antho/map_has_unknown_character.cub" "invalid" "Map avec caractère inconnu"
test_map "maps_dur/invalide_antho/map_has_void_in_the_middle.cub" "invalid" "Map avec vide au milieu"
test_map "maps_dur/invalide_antho/map_is_only_floor.cub" "invalid" "Map seulement floor"
test_map "maps_dur/invalide_antho/map_is_only_player_east.cub" "invalid" "Map seulement joueur E"
test_map "maps_dur/invalide_antho/map_is_only_player_north.cub" "invalid" "Map seulement joueur N"
test_map "maps_dur/invalide_antho/map_is_only_player_south.cub" "invalid" "Map seulement joueur S"
test_map "maps_dur/invalide_antho/map_is_only_player_west.cub" "invalid" "Map seulement joueur W"
test_map "maps_dur/invalide_antho/map_is_only_walls.cub" "invalid" "Map seulement murs"
test_map "maps_dur/invalide_antho/map_is_open.cub" "invalid" "Map ouverte"
test_map "maps_dur/invalide_antho/map_is_void.cub" "invalid" "Map vide"
test_map "maps_dur/invalide_antho/missing_map.cub" "invalid" "Map manquante"
test_map "maps_dur/invalide_antho/player_is_outside.cub" "invalid" "Joueur à l'extérieur"

# ============================================
# TESTS INVALIDES ANTHO - DIVERS
# ============================================
echo -e "\n${YELLOW}=== TESTS INVALIDES ANTHO - DIVERS ===${NC}"

test_map "maps_dur/invalide_antho/unknown_directive.cub" "invalid" "Directive inconnue"

# ============================================
# RÉSUMÉ
# ============================================
echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}              RÉSUMÉ                    ${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "Total de tests: ${TOTAL}"
echo -e "${GREEN}Tests réussis: ${PASSED}${NC}"
echo -e "${RED}Tests échoués: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ TOUS LES TESTS SONT PASSÉS !${NC}"
    exit 0
else
    echo -e "\n${RED}✗ CERTAINS TESTS ONT ÉCHOUÉ${NC}"
    exit 1
fi
