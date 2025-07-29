import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-incoherences',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './incoherences.component.html',
  styleUrls: ['./incoherences.component.css'],
})
export class IncoherencesComponent implements OnInit {
  incoherences: any[] = [];
  isLoading = true;

  constructor(private apiService: ApiService) {}

  async ngOnInit() {
    this.incoherences = await this.apiService.getIncoherences();
    this.isLoading = false;
  }
}
