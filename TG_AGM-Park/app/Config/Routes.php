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

$routes->group('estacionamentos', function ($routes) {
    $routes->post('inserir', 'Estacionamentos::inserir');
    $routes->get('listar', 'Estacionamentos::listar');
    $routes->put('atualizar/(:num)', 'Estacionamentos::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Estacionamentos::deletar/$1');
});

$routes->group('veiculos', function ($routes) {
    $routes->post('inserir', 'Veiculos::inserir');
    $routes->get('listar', 'Veiculos::listar');
    $routes->put('atualizar/(:num)', 'Veiculos::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Veiculos::deletar/$1');
});

$routes->group('vagas', function ($routes) {
    $routes->post('inserir', 'Vagas::inserir');
    $routes->get('listar', 'Vagas::listar');
    $routes->put('atualizar/(:num)', 'Vagas::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Vagas::deletar/$1');
});

$routes->group('reservas', function ($routes) {
    $routes->post('inserir', 'Reservas::inserir');
    $routes->get('listar', 'Reservas::listar');
    $routes->put('atualizar/(:num)', 'Reservas::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Reservas::deletar/$1');
});

$routes->group('estadias', function ($routes) {
    $routes->post('inserir', 'Estadias::inserir');
    $routes->get('listar', 'Estadias::listar');
    $routes->put('atualizar/(:num)', 'Estadias::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Estadias::deletar/$1');
});