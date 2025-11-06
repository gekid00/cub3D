/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   flood_fill.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: acrusoe <acrusoe@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/04/08 14:33:22 by acrusoe           #+#    #+#             */
/*   Updated: 2025/04/08 14:33:22 by acrusoe          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */
#include "cub3d.h"

int	check_flood_fill(t_data *game, int x, int y)
{
	cpy_pars(game);
	flood_fill(game, x, y);
	ft_free(game);
	return (game->path_error);
}

static int	check_bounds(t_data *game, int x, int y)
{
	if (y < 0 || y >= game->nbr)
	{
		game->path_error = 1;
		write(2, "Error\nMap not closed: player can reach outside\n", 48);
		return (1);
	}
	if (!game->pars_temp[y])
	{
		game->path_error = 1;
		write(2, "Error\nMap not closed: player can reach outside\n", 48);
		return (1);
	}
	if (x < 0 || x >= (int)ft_strlen(game->pars_temp[y]))
	{
		game->path_error = 1;
		write(2, "Error\nMap not closed: player can reach edge\n", 45);
		return (1);
	}
	return (0);
}

static int	check_flood_char(t_data *game, char c)
{
	if (c == '1' || c == 'X' || c == '#')
		return (1);
	if (is_whitespace(c) || c == '\n')
	{
		game->path_error = 1;
		write(2, "Error\nMap not closed: player can reach space\n", 46);
		return (1);
	}
	return (0);
}

void	flood_fill(t_data *game, int x, int y)
{
	char	c;

	if (check_bounds(game, x, y))
		return ;
	c = game->pars_temp[y][x];
	if (check_flood_char(game, c))
		return ;
	if (c == 'N' || c == 'S' || c == 'E' || c == 'W' || c == '0')
		game->pars_temp[y][x] = 'X';
	flood_fill(game, x + 1, y);
	flood_fill(game, x - 1, y);
	flood_fill(game, x, y + 1);
	flood_fill(game, x, y - 1);
}
