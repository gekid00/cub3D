/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   animations2.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: acrusoe <acrusoe@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/04/08 14:26:36 by acrusoe           #+#    #+#             */
/*   Updated: 2025/04/08 14:26:36 by acrusoe          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */
#include "cub3d.h"
#include "mlx.h"

void	check_position(t_data *game)
{
	game->i = 0;
	while (game->pars[game->i] != NULL)
	{
		game->j = 0;
		while (game->pars[game->i][game->j])
		{
			if (game->pars[game->i][game->j] == 'N')
				return ;
			if (game->pars[game->i][game->j] == 'S')
				return ;
			if (game->pars[game->i][game->j] == 'W')
				return ;
			if (game->pars[game->i][game->j] == 'E')
				return ;
			game->j++;
		}
		game->i++;
	}
}

int	key_hook(int keycode, t_data *game)
{
	if (keycode == KEY_W)
		game->key_w = 1;
	if (keycode == KEY_S)
		game->key_s = 1;
	if (keycode == KEY_A)
		game->key_a = 1;
	if (keycode == KEY_D)
		game->key_d = 1;
	if (keycode == KEY_LEFT)
		game->key_left = 1;
	if (keycode == KEY_RIGHT)
		game->key_right = 1;
	if (keycode == KEY_ESC)
		ft_close(game);
	return (0);
}

int	key_release(int keycode, t_data *game)
{
	if (keycode == KEY_W)
		game->key_w = 0;
	if (keycode == KEY_S)
		game->key_s = 0;
	if (keycode == KEY_A)
		game->key_a = 0;
	if (keycode == KEY_D)
		game->key_d = 0;
	if (keycode == KEY_LEFT)
		game->key_left = 0;
	if (keycode == KEY_RIGHT)
		game->key_right = 0;
	return (0);
}

int	game_loop(t_data *game)
{
	if (game->key_w)
		move_up(game, game->ray);
	if (game->key_s)
		move_down(game, game->ray);
	if (game->key_a)
		move_left(game, game->ray);
	if (game->key_d)
		move_right(game, game->ray);
	if (game->key_left)
		rotate_left(game->ray);
	if (game->key_right)
		rotate_right(game->ray);
	renderframe(game, game->ray);
	return (0);
}
