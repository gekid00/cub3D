# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: gekido <gekido@student.42.fr>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/12 01:42:13 by gekido            #+#    #+#              #
#    Updated: 2025/11/06 14:28:21 by gekido           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Colors
RED			= \033[0;31m
GREEN		= \033[0;32m
YELLOW		= \033[0;33m
BLUE		= \033[0;34m
MAGENTA		= \033[0;35m
CYAN		= \033[0;36m
RESET		= \033[0m
BOLD		= \033[1m

# Compiler
CC			= gcc

# Flags
CFLAGS		= -g -Wall -Wextra -Werror -I./includes -I./minilibx-linux

# Binary
NAME		= cub3D

# source files
SRCS	= srcs/main.c \
		srcs/parsing/check_file/parse_file.c \
		srcs/parsing/check_file/ft_doublons.c \
		srcs/parsing/check_textures/parse_textures.c \
		srcs/parsing/check_textures/check_cardinal_lines.c \
		srcs/parsing/check_colors/find_color_line.c \
		srcs/parsing/check_colors/ft_color.c \
		srcs/parsing/check_colors/check_color_lines.c \
		srcs/parsing/check_map/parse_map.c \
		srcs/parsing/check_map/check_walls.c \
		srcs/parsing/check_map/check_walls_utils.c \
		srcs/parsing/check_map/check_items.c \
	srcs/parsing/check_map/check_map_and_path.c \
	srcs/parsing/check_map/flood_fill.c \
	srcs/parsing/check_map/flood_fill_utils.c \
	srcs/raycasting/DDA.c \
	srcs/raycasting/DDA_helpers.c \
	srcs/raycasting/DDA_render.c \
	srcs/rendering/ft_render.c \
	srcs/textures/ft_texture.c \
	srcs/game/init/init_game.c \
	srcs/game/init/init_player.c \
	srcs/game/init/init_mlx.c \
	srcs/game/init/init_textures.c \
	srcs/game/player/movements.c \
	srcs/game/player/rotations.c \
	srcs/game/events/hooks.c \
	srcs/utils/get_next_line.c \
	srcs/utils/get_next_line_utils.c \
	srcs/utils/ft_memset.c \
	srcs/cleanup/cleaning.c
OBJS	= ${SRCS:.c=.o}

# mlx library
MLX_NAME	= -lmlx_Linux
MLX_PATH	= ./minilibx-linux
MLX_FLAGS   = -lXext -lX11 -lmlx -lm -lz
MLX			= -L${MLX_PATH} ${MLX_NAME} ${MLX_FLAGS}

# cub3d library
CUB3D		= includes/cub3d.h

# Progress
TOTAL		= $(words $(SRCS))
CURRENT		= 0

# Rules
all: ${NAME}

${NAME}: ${OBJS} ${CUB3D}
	@echo "${CYAN}${BOLD}"
	@echo "╔═══════════════════════════════════════════════════════════╗"
	@echo "║                    🎮 CUB3D 🎮                           ║"
	@echo "║                   Final Linking                           ║"
	@echo "╚═══════════════════════════════════════════════════════════╝"
	@echo "${RESET}"
	@echo "${YELLOW}${BOLD}[MLX]${RESET} Linking minilibx..."
	@${MAKE} -C ./minilibx-linux > /dev/null 2>&1
	@echo "${GREEN}[✓]${RESET} MiniLibX compiled"
	@echo "${YELLOW}${BOLD}[LINK]${RESET} Creating executable..."
	@${CC} ${CFLAGS} ${OBJS} ${MLX} -o $(NAME)
	@echo "${GREEN}${BOLD}"
	@echo "╔═══════════════════════════════════════════════════════════╗"
	@echo "║                  ✨ BUILD SUCCESS ✨                      ║"
	@echo "║              ./cub3D is ready to run!                     ║"
	@echo "╚═══════════════════════════════════════════════════════════╝"
	@echo "${RESET}"

%.o: %.c
	@$(eval CURRENT=$(shell echo $$(($(CURRENT)+1))))
	@$(eval PERCENT=$(shell echo $$(($(CURRENT)*100/$(TOTAL)))))
	@printf "${CYAN}[%3d%%]${RESET} ${MAGENTA}Compiling${RESET} %-50s" $(PERCENT) "$<"
	@${CC} ${CFLAGS} -c $< -o $@
	@echo "${GREEN}✓${RESET}"

clean:
	@echo "${RED}${BOLD}[CLEAN]${RESET} Removing object files..."
	@rm -rf ${OBJS}
	@echo "${YELLOW}[MLX]${RESET} Cleaning minilibx..."
	@${MAKE} -C ./minilibx-linux clean > /dev/null 2>&1
	@echo "${GREEN}[✓]${RESET} Clean complete"

fclean: clean
	@echo "${RED}${BOLD}[FCLEAN]${RESET} Removing executable..."
	@rm -rf ${NAME}
	@echo "${GREEN}[✓]${RESET} Full clean complete"

re: fclean all

.PHONY: all clean fclean re