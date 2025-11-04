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
	flood_fill(game, x, y);
	return (game->path_error);
}

void	flood_fill(t_data *game, int x, int y)
{
	char	original_char;

	if (y < 0 || x < 0 || !game->pars_temp[y])
	{
		game->path_error = 1;
		write(2, "Error\nMap not closed: player can reach outside\n", 48);
		return ;
	}
	if (x >= (int)ft_strlen(game->pars_temp[y]))
	{
		game->path_error = 1;
		write(2, "Error\nMap not closed: player can reach outside\n", 48);
		return ;
	}
	if (game->pars_temp[y][x] == '1')
		return ;
	if (game->pars_temp[y][x] == 'X')
		return ;
	if (x >= (int)ft_strlen(game->pars[y]) || game->pars[y][x] == '\n')
		return ;
	original_char = game->pars[y][x];
	if (is_whitespace(original_char))
	{
		game->path_error = 1;
		write(2, "Error\nMap not closed: player can reach outside\n", 48);
		return ;
	}
	if (original_char == 'N' || original_char == 'S' ||
			original_char == 'E' || original_char == 'W'
			|| original_char == '0')
		game->pars_temp[y][x] = 'X';
	flood_fill(game, x + 1, y);
	flood_fill(game, x - 1, y);
	flood_fill(game, x, y + 1);
	flood_fill(game, x, y - 1);
}

void	ft_strcpy(char *str, char *str1, int max_len)
{
	int	i;

	i = 0;
	while (str1[i] != '\n' && str1[i] != '\0')
	{
		str[i] = str1[i];
		i++;
	}
	while (i < max_len)
	{
		str[i] = ' ';
		i++;
	}
	str[i] = '\0';
}

char	**cpy_pars(t_data *game)
{
	int	i;
	int	max_len;

	i = 0;
	max_len = len(game);
	game->pars_temp = malloc(((game->nbr) + 1) * sizeof(char *));
	while (game->pars[i])
	{
		game->pars_temp[i] = malloc((max_len + 1) * sizeof(char));
		ft_strcpy(game->pars_temp[i], game->pars[i], max_len);
		i++;
	}
	game->pars_temp[i] = NULL;
	return (game->pars_temp);
}

void	ft_free(t_data *game)
{
	int	i;

	i = 0;
	while (game->pars_temp[i])
	{
		free(game->pars_temp[i]);
		i++;
	}
	free(game->pars_temp);
}
