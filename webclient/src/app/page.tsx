"use client";

import { DataGrid, GridRowsProp, GridColDef } from "@mui/x-data-grid";
import { useEffect, useState } from "react";

const rows: GridRowsProp = [
  { id: 1, col1: "Hello", col2: "World" },
  { id: 2, col1: "DataGridPro", col2: "is Awesome" },
  { id: 3, col1: "MUI", col2: "is Amazing" },
];

const columns: GridColDef[] = [
  { field: "col1", headerName: "Column 1", width: 150 },
  { field: "col2", headerName: "Column 2", width: 150 },
];

export default function Home() {
  const [data, setData] = useState(null as any);

  async function fetchData() {
    const url = "http://localhost:3000/residents";

    const response = await fetch(url);

    const data = await response.json();

    console.log(data);
  }

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <main>
      <div style={{ height: 300, width: "100%" }}>
        <DataGrid rows={rows} columns={columns} />
      </div>
    </main>
  );
}
