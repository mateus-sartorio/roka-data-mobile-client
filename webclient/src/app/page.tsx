"use client";

import { DataGrid, GridRowsProp, GridColDef } from "@mui/x-data-grid";
import { useEffect, useState } from "react";
import { ResidentResponseDTO } from "./DTOs/response/ResidentResponseDTO";
import { Resident } from "./models/Resident";
import { Collect } from "./models/Collect";
import { Situation } from "./enums/Situation";

// const rows: GridRowsProp = [
//   { id: 1, col1: "Hello", col2: "World", col3: "a" },
//   { id: 2, col1: "DataGridPro", col2: "is Awesome" },
//   { id: 3, col1: "MUI", col2: "is Amazing" },
// ];

const columns: GridColDef[] = [
  { field: "col1", headerName: "Nome", width: 150 },
  { field: "col2", headerName: "Endereço", width: 150 },
  { field: "col3", headerName: "Data de nascimento", width: 150 },
  { field: "col4", headerName: "Tem plaquinha", width: 150 },
  { field: "col5", headerName: "Está no grupo do WhatsApp?", width: 150 },
  { field: "col6", headerName: "Reside em Jesus de Nazareth?", width: 150 },
  { field: "col7", headerName: "Observações", width: 150 },
  { field: "col8", headerName: "Telefone", width: 150 },
  { field: "col9", headerName: "Profissão", width: 150 },
  { field: "col10", headerName: "Ponto de referência", width: 150 },
  { field: "col11", headerName: "Ano de cadastro", width: 150 },
  { field: "col12", headerName: "Quantidade de residentes na casa", width: 150 },
  { field: "col13", headerName: "ID da ROKA", width: 150 },
  { field: "col14", headerName: "Situação", width: 150 },
];

export default function Home() {
  const [rows, setRows] = useState([] as GridRowsProp);

  async function fetchData() {
    const url = "http://localhost:3000/residents";

    const response = await fetch(url);

    const data: ResidentResponseDTO[] = await response.json();

    const parsedResidents: GridRowsProp = data.map((element) => {
      const { id, address, birthdate, collect, created_at, has_plaque, is_on_whatsapp_group, lives_in_JN, name, observations, phone, profession, reference_point, registration_year, residents_in_the_house, roka_id, situation, updated_at } = element;

      // const collects: Collect[] = collect.map((c) => {
      //   const { ammount, collected_on, created_at, id, resident_id, updated_at } = c;

      //   return { ammount: Number(ammount), collected_on: new Date(collected_on), created_at: new Date(created_at), id: Number(id), resident_id: Number(resident_id), updated_at: new Date(updated_at) };
      // });

      return {
        id: Number(id),
        col1: name,
        col2: address,
        col3: new Date(birthdate),
        col4: has_plaque,
        col5: is_on_whatsapp_group,
        col6: lives_in_JN,
        col7: observations,
        col8: phone,
        col9: profession,
        col10: reference_point,
        col11: registration_year,
        col12: residents_in_the_house,
        col13: roka_id,
        col14: Number(situation) as Situation,
      };
    });

    setRows(parsedResidents);
  }

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <main style={{ height: "100vh" }}>
      <DataGrid rows={rows} columns={columns} />
    </main>
  );
}
