<?php

namespace App\Models;

use CodeIgniter\Model;

class Estacionamento_model extends Model {

    public function inserir($data) {
        return $this->db->insert('estacionamentos', $data);
    }

    public function listar() {
        return $this->db->get('estacionamentos')->result();
    }

    public function buscar_por_id($id) {
        return $this->db->get_where('estacionamentos', ['id_estacionamento' => $id])->row();
    }

    public function atualizar($id, $data) {
        $this->db->where('id_estacionamento', $id);
        return $this->db->update('estacionamentos', $data);
    }

    public function deletar($id) {
        return $this->db->delete('estacionamentos', ['id_estacionamento' => $id]);
    }
}