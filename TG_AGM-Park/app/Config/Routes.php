<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');

$routes->group('usuarios', function ($routes) {
    $routes->post('inserir', 'Usuarios::inserir');
    $routes->get('listar', 'Usuarios::listar');
    $routes->get('(:num)', 'Usuarios::buscar/$1');
    $routes->put('atualizar/(:num)', 'Usuarios::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Usuarios::deletar/$1');
});

