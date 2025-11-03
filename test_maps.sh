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
    timeout 3 valgrind $VALGRIND_OPTS ./cub3D "$map" > /dev/null 2>&1
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
echo -e "${YELLOW}    CUB3D MAP VALIDATION TEST SUITE    ${NC}"
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

test_map "test_maps/valid/spawn_north.cub" "valid" "Spawn orientation NORTH"
test_map "test_maps/valid/spawn_south.cub" "valid" "Spawn orientation SOUTH"
test_map "test_maps/valid/spawn_east.cub" "valid" "Spawn orientation EAST"
test_map "test_maps/valid/spawn_west.cub" "valid" "Spawn orientation WEST"
test_map "test_maps/valid/big_map.cub" "valid" "Grande map valide"
test_map "test_maps/valid/tiny_map.cub" "valid" "Petite map valide"
test_map "test_maps/valid/map_not_closed_top.cub" "valid" "Map avec espace non accessible en haut"
test_map "test_maps/valid/map_not_closed_bottom.cub" "valid" "Map avec espace non accessible en bas"
test_map "test_maps/valid/empty_line_in_map.cub" "valid" "Map avec lignes vides avant la map"
test_map "test_maps/valid/no_newline_before_map.cub" "valid" "Map avec newline avant la map"

# ============================================
# TESTS DE BIG MAPS TRICKY
# ============================================
echo -e "\n${YELLOW}=== TESTS DE BIG MAPS AVEC CAS TRICKY ===${NC}"

test_map "test_maps/valid/big_map_irregular.cub" "valid" "Big map avec lignes irrégulières"
test_map "test_maps/valid/big_map_wide.cub" "valid" "Big map très large (50 colonnes)"
test_map "test_maps/valid/big_map_tall.cub" "valid" "Big map très haute (40 lignes)"
test_map "test_maps/valid/big_map_complex.cub" "valid" "Big map complexe avec salles internes"
test_map "test_maps/valid/Big_map.cub" "valid" "Big map avec plusieurs îles et espaces"
test_map "test_maps/valid/map_with_spaces_like_subject.cub" "valid" "Map avec espaces comme dans le sujet"

# ============================================
# TESTS DE CONFIGURATION INVALIDE
# ============================================
echo -e "\n${YELLOW}=== TESTS DE CONFIGURATION INVALIDE ===${NC}"

test_map "test_maps/invalid/missing_ea_texture.cub" "invalid" "Texture EA manquante"
test_map "test_maps/invalid/missing_floor_color.cub" "invalid" "Couleur sol manquante"
test_map "test_maps/invalid/missing_ceiling_color.cub" "invalid" "Couleur plafond manquante"
test_map "test_maps/invalid/double_no_texture.cub" "invalid" "Double déclaration NO"
test_map "test_maps/invalid/double_floor_color.cub" "invalid" "Double déclaration F"
test_map "test_maps/invalid/invalid_texture_path.cub" "invalid" "Chemin de texture invalide"
test_map "test_maps/invalid/unknown_identifier.cub" "invalid" "Identifiant inconnu"

# ============================================
# TESTS DE COULEURS INVALIDES
# ============================================
echo -e "\n${YELLOW}=== TESTS DE COULEURS INVALIDES ===${NC}"

test_map "test_maps/invalid/color_out_of_range.cub" "invalid" "Couleur hors limite (>255)"
test_map "test_maps/invalid/negative_color.cub" "invalid" "Couleur négative"
test_map "test_maps/invalid/incomplete_color.cub" "invalid" "Couleur incomplète (RGB incomplet)"

# ============================================
# TESTS DE MAP INVALIDE
# ============================================
echo -e "\n${YELLOW}=== TESTS DE MAP INVALIDE ===${NC}"

test_map "test_maps/invalid/no_player.cub" "invalid" "Pas de joueur"
test_map "test_maps/invalid/multiple_players.cub" "invalid" "Plusieurs joueurs"
test_map "test_maps/invalid/map_not_closed_left.cub" "invalid" "Map ouverte à gauche"
test_map "test_maps/invalid/map_not_closed_right.cub" "invalid" "Map ouverte à droite"
test_map "test_maps/invalid/invalid_character.cub" "invalid" "Caractère invalide dans map"
test_map "test_maps/invalid/empty_line_in_middle_of_map.cub" "invalid" "Ligne vide au milieu de la map"
test_map "test_maps/invalid/no_map.cub" "invalid" "Pas de map"
test_map "test_maps/invalid/map_weird_1.cub" "invalid" "Map bizarre 1 (lignes inégales + espace)"
test_map "test_maps/invalid/map_weird_2.cub" "invalid" "Map bizarre 2 (commence par espace)"

# ============================================
# TESTS DE BIG MAPS INVALIDES
# ============================================
echo -e "\n${YELLOW}=== TESTS DE BIG MAPS INVALIDES ===${NC}"

test_map "test_maps/invalid/big_map_empty_line.cub" "invalid" "Big map avec ligne vide au milieu"
test_map "test_maps/invalid/big_map_hole_middle.cub" "invalid" "Big map avec trou au milieu (espace)"
test_map "test_maps/invalid/big_map_space_border.cub" "invalid" "Big map avec espace au bord gauche"
test_map "test_maps/invalid/big_map_open_bottom.cub" "invalid" "Big map ouverte en bas (ligne 0 après mur)"
test_map "test_maps/invalid/big_map_hole_right.cub" "invalid" "Big map avec trou au bord droit"

# ============================================
# TESTS AVANCÉS : ERREURS DE CONFIGURATION
# ============================================
echo -e "\n${YELLOW}=== TESTS AVANCÉS: ERREURS DE CONFIGURATION ===${NC}"

test_map "test_maps/invalid_advanced/config_all_missing.cub" "invalid" "Aucune configuration"
test_map "test_maps/invalid_advanced/config_triple_no.cub" "invalid" "Triple déclaration NO"
test_map "test_maps/invalid_advanced/config_color_256.cub" "invalid" "Couleur = 256"
test_map "test_maps/invalid_advanced/config_color_empty_value.cub" "invalid" "Couleur avec valeur vide"
test_map "test_maps/invalid_advanced/config_color_float.cub" "invalid" "Couleur avec float"
test_map "test_maps/invalid_advanced/config_color_four_values.cub" "invalid" "Couleur avec 4 valeurs"
test_map "test_maps/invalid_advanced/config_texture_no_path.cub" "invalid" "Texture sans chemin"
test_map "test_maps/invalid_advanced/config_unknown_id.cub" "invalid" "Identifiant inconnu XY"
test_map "test_maps/invalid_advanced/config_double_ceiling.cub" "invalid" "Double couleur plafond"
test_map "test_maps/invalid_advanced/config_color_negative_one.cub" "invalid" "Couleur -1"

# ============================================
# TESTS AVANCÉS : ERREURS DE STRUCTURE
# ============================================
echo -e "\n${YELLOW}=== TESTS AVANCÉS: ERREURS DE STRUCTURE ===${NC}"

test_map "test_maps/invalid_advanced/structure_no_map_at_all.cub" "invalid" "Pas de map du tout"
test_map "test_maps/invalid_advanced/structure_empty_lines_in_map.cub" "invalid" "Lignes vides dans la map"
test_map "test_maps/invalid_advanced/structure_tab_in_map.cub" "invalid" "Tab dans la map"
test_map "test_maps/invalid_advanced/structure_text_after_map.cub" "invalid" "Texte après la map"
test_map "test_maps/invalid_advanced/structure_no_newline_before_map.cub" "invalid" "Pas de newline avant map"
test_map "test_maps/invalid_advanced/structure_super_long_line.cub" "invalid" "Ligne extrêmement longue"
test_map "test_maps/invalid_advanced/structure_one_char_map.cub" "invalid" "Map d'un seul caractère"
test_map "test_maps/invalid_advanced/structure_special_char_at.cub" "invalid" "Caractère spécial @"
test_map "test_maps/invalid_advanced/structure_only_three_lines.cub" "invalid" "Seulement 3 lignes"
test_map "test_maps/invalid_advanced/structure_irregular_last_line.cub" "invalid" "Dernière ligne irrégulière"

# ============================================
# TESTS AVANCÉS : ERREURS DE FERMETURE
# ============================================
echo -e "\n${YELLOW}=== TESTS AVANCÉS: ERREURS DE FERMETURE ===${NC}"

test_map "test_maps/invalid_advanced/walls_all_start_with_space.cub" "invalid" "Toutes lignes commencent par espace"
test_map "test_maps/invalid_advanced/walls_space_in_top_right.cub" "invalid" "Espace en haut à droite"
test_map "test_maps/invalid_advanced/walls_space_next_to_player.cub" "invalid" "Espace à côté du joueur"
test_map "test_maps/invalid_advanced/walls_corner_missing_bottom_right.cub" "invalid" "Coin manquant bas droite"
test_map "test_maps/invalid_advanced/walls_corner_missing_top_left.cub" "invalid" "Coin manquant haut gauche"
test_map "test_maps/invalid_advanced/walls_hole_in_bottom_wall.cub" "invalid" "Trou dans le mur du bas"
test_map "test_maps/invalid_advanced/walls_zero_on_left_middle.cub" "invalid" "Zero sur le bord gauche"
test_map "test_maps/invalid_advanced/walls_isolated_wall_inside.cub" "invalid" "Mur isolé à l'intérieur"
test_map "test_maps/invalid_advanced/walls_zero_bottom_corner.cub" "invalid" "Zero dans le coin du bas"
test_map "test_maps/invalid_advanced/walls_all_spaces_inside.cub" "invalid" "Espaces partout à l'intérieur"

# ============================================
# TESTS AVANCÉS : ERREURS DE JOUEUR
# ============================================
echo -e "\n${YELLOW}=== TESTS AVANCÉS: ERREURS DE JOUEUR ===${NC}"

test_map "test_maps/invalid_advanced/player_missing.cub" "invalid" "Joueur manquant"
test_map "test_maps/invalid_advanced/player_two_directions.cub" "invalid" "Deux directions (N et S)"
test_map "test_maps/invalid_advanced/player_two_on_same_line.cub" "invalid" "Deux joueurs sur même ligne"
test_map "test_maps/invalid_advanced/player_wrong_direction_X.cub" "invalid" "Direction X invalide"
test_map "test_maps/invalid_advanced/player_lowercase_n.cub" "invalid" "Direction minuscule n"
test_map "test_maps/invalid_advanced/player_four_players.cub" "invalid" "Quatre joueurs"
test_map "test_maps/invalid_advanced/player_number_two.cub" "invalid" "Chiffre 2 au lieu de joueur"
test_map "test_maps/invalid_advanced/player_alone_no_walls.cub" "invalid" "Joueur seul sans murs"
test_map "test_maps/invalid_advanced/player_surrounded_by_walls.cub" "invalid" "Joueur entouré de murs"
test_map "test_maps/invalid_advanced/player_15_players.cub" "invalid" "15 joueurs"

# ============================================
# TESTS AVANCÉS : EDGE CASES EXTRÊMES
# ============================================
echo -e "\n${YELLOW}=== TESTS AVANCÉS: EDGE CASES EXTRÊMES ===${NC}"

test_map "test_maps/invalid_advanced/extreme_color_overflow.cub" "invalid" "Overflow couleur (4294967295)"
test_map "test_maps/invalid_advanced/extreme_2x2_map.cub" "invalid" "Map 2x2"
test_map "test_maps/invalid_advanced/extreme_very_tall.cub" "invalid" "Map très haute (50 lignes)"
test_map "test_maps/invalid_advanced/extreme_very_wide.cub" "invalid" "Map très large"
test_map "test_maps/invalid_advanced/extreme_extra_line_after.cub" "invalid" "Lignes supplémentaires après map"
test_map "test_maps/invalid_advanced/extreme_single_column.cub" "invalid" "Une seule colonne"
test_map "test_maps/invalid_advanced/extreme_single_row.cub" "invalid" "Une seule ligne"
test_map "test_maps/invalid_advanced/extreme_line_cut_short.cub" "invalid" "Ligne coupée court"
test_map "test_maps/invalid_advanced/extreme_color_lots_of_spaces.cub" "invalid" "Couleur avec beaucoup d'espaces"
test_map "test_maps/invalid_advanced/extreme_all_black.cub" "invalid" "Tout noir (0,0,0)"

# Test sans arguments
echo -e "\n${BLUE}Test $((TOTAL + 1)): Programme sans arguments${NC}"
TOTAL=$((TOTAL + 1))
./cub3D > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} - Erreur détectée sans arguments"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} - Aucune erreur sans arguments"
    FAILED=$((FAILED + 1))
fi

# Test avec fichier inexistant
echo -e "\n${BLUE}Test $((TOTAL + 1)): Fichier inexistant${NC}"
TOTAL=$((TOTAL + 1))
./cub3D nonexistent.cub > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} - Erreur détectée pour fichier inexistant"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} - Aucune erreur pour fichier inexistant"
    FAILED=$((FAILED + 1))
fi

# Test avec mauvaise extension
echo -e "\n${BLUE}Test $((TOTAL + 1)): Mauvaise extension (.txt)${NC}"
TOTAL=$((TOTAL + 1))
touch /tmp/test.txt
./cub3D /tmp/test.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} - Erreur détectée pour mauvaise extension"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} - Aucune erreur pour mauvaise extension"
    FAILED=$((FAILED + 1))
fi
rm -f /tmp/test.txt

# Test avec mauvaise extension (.cu)
echo -e "\n${BLUE}Test $((TOTAL + 1)): Extension presque valide (.cu)${NC}"
TOTAL=$((TOTAL + 1))
cp test_maps/valid/spawn_north.cub /tmp/test.cu
./cub3D /tmp/test.cu > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} - Erreur détectée pour extension .cu"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} - Aucune erreur pour extension .cu"
    FAILED=$((FAILED + 1))
fi
rm -f /tmp/test.cu

# Test avec trop d'arguments
echo -e "\n${BLUE}Test $((TOTAL + 1)): Trop d'arguments${NC}"
TOTAL=$((TOTAL + 1))
./cub3D test_maps/valid/spawn_north.cub extra_arg > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} - Erreur détectée pour trop d'arguments"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC} - Aucune erreur pour trop d'arguments"
    FAILED=$((FAILED + 1))
fi

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
