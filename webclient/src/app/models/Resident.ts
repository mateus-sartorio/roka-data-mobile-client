import { Situation } from "../enums/Situation";
import { Collect } from "./Collect";

export interface Resident {
  id: number;
  address: string;
  birthdate: Date;
  collects: Collect[];
  created_at: Date;
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
  situation: Situation;
  updated_at: Date;
}
