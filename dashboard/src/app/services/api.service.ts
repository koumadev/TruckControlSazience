import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private baseUrl = 'http://localhost:3000/api';

  constructor(private http: HttpClient) {}

  async getDeparts(): Promise<any[]> {
    try {
      return await firstValueFrom(
        this.http.get<any[]>(`${this.baseUrl}/departs`)
      );
    } catch (error) {
      console.error('Erreur lors de la récupération des départs :', error);
      return [];
    }
  }

  async getDepartById(id: number): Promise<any | null> {
    try {
      return await firstValueFrom(
        this.http.get<any>(`${this.baseUrl}/departs/${id}`)
      );
    } catch (error) {
      console.error(`Erreur lors de la récupération du départ ${id} :`, error);
      return null;
    }
  }

  async getIncoherences(): Promise<any[]> {
    try {
      return await firstValueFrom(
        this.http.get<any[]>(`${this.baseUrl}/incoherences`)
      );
    } catch (error) {
      console.error('Erreur lors de la récupération des incohérences :', error);
      return [];
    }
  }

  async getDepartsEnCours(): Promise<any[]> {
    try {
      return await firstValueFrom(
        this.http.get<any[]>(`${this.baseUrl}/departs/en-cours`)
      );
    } catch (error) {
      console.error(
        'Erreur lors de la récupération des départs en cours :',
        error
      );
      return [];
    }
  }
}
