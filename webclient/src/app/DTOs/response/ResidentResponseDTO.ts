import { CollectResponseDTO } from "./CollectResponseDTO";

export interface ResidentResponseDTO {
  id: number;
  address: string;
  birthdate: string;
  collect: CollectResponseDTO[];
  created_at: string;
  has_plaque: boolean;
  is_on_whatsapp_group: boolean;
  lives_in_JN: boolean;
  name: string;
  observations: string;
  phone: string;
  profession: string;
  reference_point: string;
  registration_year: number;
  residents_in_the_house: number;
  roka_id: number;
  situation: number;
  updated_at: string;
}
