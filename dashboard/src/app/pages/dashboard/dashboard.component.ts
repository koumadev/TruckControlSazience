import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css'],
})
export class DashboardComponent implements OnInit {
  departs: any[] = [];
  filteredDeparts: any[] = [];
  searchQuery = '';
  sortColumn = '';
  sortDirection: 'asc' | 'desc' = 'asc';
  currentPage = 1;
  itemsPerPage = 5;
  isLoading = true;

  constructor(private api: ApiService) {}

  async ngOnInit() {
    try {
      this.departs = await this.api.getDeparts();
      this.filteredDeparts = [...this.departs];
    } catch (err) {
      console.error('Erreur lors du chargement des départs', err);
    } finally {
      this.isLoading = false;
    }
  }

  search() {
    const query = this.searchQuery.toLowerCase();
    this.filteredDeparts = this.departs.filter((d) =>
      Object.values(d).some((val) => String(val).toLowerCase().includes(query))
    );
    this.currentPage = 1;
  }

  sort(column: string) {
    if (this.sortColumn === column) {
      this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortColumn = column;
      this.sortDirection = 'asc';
    }
    this.filteredDeparts.sort((a, b) => {
      if (a[column] < b[column]) return this.sortDirection === 'asc' ? -1 : 1;
      if (a[column] > b[column]) return this.sortDirection === 'asc' ? 1 : -1;
      return 0;
    });
  }

  get paginatedDeparts() {
    const start = (this.currentPage - 1) * this.itemsPerPage;
    return this.filteredDeparts.slice(start, start + this.itemsPerPage);
  }

  totalPages() {
    return Math.ceil(this.filteredDeparts.length / this.itemsPerPage);
  }

  changePage(page: number) {
    this.currentPage = page;
  }
}
