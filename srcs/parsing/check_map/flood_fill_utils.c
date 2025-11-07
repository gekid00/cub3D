/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   flood_fill_utils.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gekido <gekido@student.42.fr>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 14:30:00 by gekido            #+#    #+#             */
/*   Updated: 2025/11/06 23:08:23 by gekido           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "cub3d.h"

int	get_max_len(t_data *game)
{
	int	i;
	int	max;
	int	len;

	i = 0;
	max = 0;
	while (game->pars[i])
	{
		len = 0;
		while (game->pars[i][len] && game->pars[i][len] != '\n')
			len++;
		if (len > max)
			max = len;
		i++;
	}
	return (max);
}

void	ft_strcpy(char *str, char *str1, int max_len)
{
	int	i;

	i = 0;
	while (str1[i] && str1[i] != '\n')
	{
		str[i] = str1[i];
		i++;
	}
	while (i < max_len)
	{
		str[i] = '#';
		i++;
	}
	str[i] = '\0';
}

char	**cpy_pars(t_data *game)
{
	int	i;
	int	max_len;

	i = 0;
	max_len = get_max_len(game);
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
