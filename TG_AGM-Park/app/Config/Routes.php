<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');

// Autenticação
$routes->post('auth/login', 'Auth::login');
$routes->get('auth/checkauth', 'Auth::checkAuth', ['filter' => 'jwt']);

// Cadastro publico para permitir login apos criar conta.
$routes->post('usuarios/inserir', 'Usuarios::inserir');
$routes->get('usuarios/me', 'Usuarios::me', ['filter' => 'jwt']);
$routes->put('usuarios/me', 'Usuarios::atualizarMe', ['filter' => 'jwt']);

// Apenas PROPRIETARIO pode manipular usuários
$routes->group('usuarios', ['filter' => ['jwt', 'role:PROPRIETARIO']], function ($routes) {
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
    // Funcionário tem acesso a todos endpoints de veículos
    $routes->post('inserir', 'Veiculos::inserir', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
    $routes->get('listar', 'Veiculos::listar', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
    $routes->put('atualizar/(:num)', 'Veiculos::atualizar/$1', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
    $routes->delete('deletar/(:num)', 'Veiculos::deletar/$1', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
});

// Vagas: FUNCIONARIO pode ler e atualizar; inserir e deletar apenas ADMIN
$routes->group('vagas', function ($routes) {
    $routes->post('inserir', 'Vagas::inserir', ['filter' => ['jwt', 'role:PROPRIETARIO']]);
    $routes->get('listar', 'Vagas::listar', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
    $routes->put('disponibilidade/(:num)', 'Vagas::alterarDisponibilidade/$1', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
    $routes->put('atualizar/(:num)', 'Vagas::atualizar/$1', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
    $routes->put('atualizar-status-fisico/(:num)', 'Vagas::atualizarStatusFisico/$1');
    $routes->delete('deletar/(:num)', 'Vagas::deletar/$1', ['filter' => ['jwt', 'role:PROPRIETARIO']]);
});

$routes->group('reservas', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']], function ($routes) {
    $routes->post('inserir', 'Reservas::inserir');
    $routes->get('listar', 'Reservas::listar');
    $routes->put('atualizar/(:num)', 'Reservas::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Reservas::deletar/$1');
});

$routes->group('estadias', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']], function ($routes) {
    $routes->post('inserir', 'Estadias::inserir');
    $routes->get('listar', 'Estadias::listar');
    $routes->put('atualizar/(:num)', 'Estadias::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Estadias::deletar/$1');
});

$routes->group('pagamentos', function ($routes) {
    $routes->post('inserir', 'Pagamentos::inserir');
    $routes->get('listar', 'Pagamentos::listar');
    $routes->put('atualizar/(:num)', 'Pagamentos::atualizar/$1');
    $routes->delete('deletar/(:num)', 'Pagamentos::deletar/$1');
});

$routes->group('FuncionarioEstacionamento', function ($routes) {
    $routes->post('inserir', 'FuncionarioEstacionamento::inserir', ['filter' => ['jwt', 'role:PROPRIETARIO']]);
    $routes->get('listar', 'FuncionarioEstacionamento::listar', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
    $routes->put('atualizar/(:num)', 'FuncionarioEstacionamento::atualizar/$1', ['filter' => ['jwt', 'role:PROPRIETARIO']]);
    $routes->delete('deletar/(:num)', 'FuncionarioEstacionamento::deletar/$1', ['filter' => ['jwt', 'role:PROPRIETARIO']]);
});

$routes->group('HorariosFuncionamento', function ($routes) {
    $routes->post('inserir', 'HorariosFuncionamento::inserir');
    $routes->get('listar', 'HorariosFuncionamento::listar');
    $routes->put('atualizar/(:num)', 'HorariosFuncionamento::atualizar/$1');
    $routes->delete('deletar/(:num)', 'HorariosFuncionamento::deletar/$1');
});

// Tarifas: FUNCIONARIO apenas leitura; alterações somente ADMIN
$routes->group('tarifas', function ($routes) {
    $routes->post('inserir', 'Tarifas::inserir', ['filter' => ['jwt', 'role:PROPRIETARIO']]);
    $routes->get('listar', 'Tarifas::listar', ['filter' => ['jwt', 'role:PROPRIETARIO,FUNCIONARIO']]);
    $routes->put('atualizar/(:num)', 'Tarifas::atualizar/$1', ['filter' => ['jwt', 'role:PROPRIETARIO']]);
    $routes->delete('deletar/(:num)', 'Tarifas::deletar/$1', ['filter' => ['jwt', 'role:PROPRIETARIO']]);
});
