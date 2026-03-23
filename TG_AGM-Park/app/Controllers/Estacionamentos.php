<?php
class Estacionamentos extends CI_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('Estacionamento_model');
    }

    public function index() {
        $data['estacionamentos'] = $this->Estacionamento_model->listar();
        $this->load->view('estacionamentos/index', $data);
    }

    public function criar() {
        if ($this->input->post()) {
            $dados = $this->input->post();
            $this->Estacionamento_model->inserir($dados);
            redirect('estacionamentos');
        }
        $this->load->view('estacionamentos/criar');
    }

    public function editar($id) {
        if ($this->input->post()) {
            $dados = $this->input->post();
            $this->Estacionamento_model->atualizar($id, $dados);
            redirect('estacionamentos');
        }
        $data['estacionamento'] = $this->Estacionamento_model->buscar_por_id($id);
        $this->load->view('estacionamentos/editar', $data);
    }

    public function deletar($id) {
        $this->Estacionamento_model->deletar($id);
        redirect('estacionamentos');
    }
}