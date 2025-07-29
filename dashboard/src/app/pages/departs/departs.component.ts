import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-departs',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './departs.component.html',
  styleUrls: ['./departs.component.css'],
})
export class DepartsComponent implements OnInit {
  departs: any[] = [];
  isLoading = true;

  constructor(private apiService: ApiService) {}

  ngOnInit() {
    this.loadDepartsEnCours();
  }

  loadDepartsEnCours() {
    this.apiService
      .getDepartsEnCours()
      .then((data) => {
        this.departs = data;
        this.isLoading = false;
      })
      .catch((err) => {
        console.error('Erreur lors du chargement des départs :', err);
        this.isLoading = false;
      });
  }
}
