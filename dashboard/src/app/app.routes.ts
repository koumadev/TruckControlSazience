import { Routes } from '@angular/router';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { DepartsComponent } from './pages/departs/departs.component';
import { IncoherencesComponent } from './pages/incoherences/icoherences.component';

export const routes: Routes = [
  { path: '', component: DashboardComponent },
  { path: 'departs', component: DepartsComponent },
  { path: 'incoherences', component: IncoherencesComponent },
];
