"use client";

import { DataGrid, GridRowsProp, GridColDef } from "@mui/x-data-grid";
import { useEffect, useState } from "react";
import { ResidentResponseDTO } from "./DTOs/response/ResidentResponseDTO";
import { boolToPortugueseString } from "./utils/boolean_conversion";
import { situationEnumConverter } from "./utils/situationEnumConverter";

// const rows: GridRowsProp = [
//   { id: 1, col1: "Hello", col2: "World", col3: "a" },
//   { id: 2, col1: "DataGridPro", col2: "is Awesome" },
//   { id: 3, col1: "MUI", col2: "is Amazing" },
// ];

const columns: GridColDef[] = [
  { field: "col1", headerName: "Nome", width: 300, headerAlign: "center", align: "center", flex: 1 },
  { field: "col2", headerName: "ID da ROKA", width: 200, headerAlign: "center", align: "center", flex: 1 },
  { field: "col3", headerName: "Situação", width: 200, headerAlign: "center", align: "center", flex: 1 },
  { field: "col4", headerName: "Endereço", width: 300, headerAlign: "center", align: "center", flex: 1 },
  { field: "col5", headerName: "Ponto de referência", width: 300, headerAlign: "center", align: "center", flex: 1 },
  { field: "col6", headerName: "Telefone", width: 200, headerAlign: "center", align: "center", flex: 1 },
  { field: "col7", headerName: "Está no grupo do WhatsApp?", width: 200, headerAlign: "center", align: "center", flex: 1 },
  // { field: "col3", headerName: "Data de nascimento", width: 150 },
  // { field: "col4", headerName: "Tem plaquinha", width: 150 },
  // { field: "col6", headerName: "Reside em Jesus de Nazareth?", width: 150 },
  // { field: "col7", headerName: "Observações", width: 150 },
  // { field: "col9", headerName: "Profissão", width: 150 },
  // { field: "col11", headerName: "Ano de cadastro", width: 150 },
  // { field: "col12", headerName: "Quantidade de residentes na casa", width: 150 },
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
        col2: roka_id,
        col3: situationEnumConverter(situation),
        col4: address,
        col5: reference_point,
        col6: phone,
        col7: boolToPortugueseString(is_on_whatsapp_group),
        // col8: phone,
        // col9: profession,
        // col10: reference_point,
        // col11: registration_year,
        // col12: residents_in_the_house,
        // col13: roka_id,
        // col14: Number(situation) as Situation,
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
