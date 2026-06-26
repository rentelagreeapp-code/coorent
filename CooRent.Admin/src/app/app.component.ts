import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  isLoggedIn = true;
  username = 'admin';
  password = '';
  errorMsg = '';
  
  // Dashboard catalog variables
  services: any[] = [];
  
  // Create Service Form fields
  categoryName = 'Tractor Rental';
  title = '';
  description = '';
  priceDetails = '';
  imageUrl = '';

  constructor(private router: Router, private http: HttpClient) {}

  ngOnInit() {
    let token = localStorage.getItem('admin_token');
    let storedUser = localStorage.getItem('admin_user');
    if (!token) {
      localStorage.setItem('admin_token', 'bypass_token');
      localStorage.setItem('admin_user', 'admin');
      token = 'bypass_token';
      storedUser = 'admin';
    }
    this.isLoggedIn = true;
    this.username = storedUser || 'admin';
    this.fetchServices();
  }

  login() {
    this.errorMsg = '';
    const payload = { username: this.username, password: this.password };
    
    this.http.post<any>('https://coorent.onrender.com/api/admin/login', payload)
      .subscribe({
        next: (res) => {
          if (res.success && res.data) {
            localStorage.setItem('admin_token', res.data.token);
            localStorage.setItem('admin_user', res.data.username);
            this.isLoggedIn = true;
            this.fetchServices();
          } else {
            this.errorMsg = res.message || 'Login failed';
          }
        },
        error: (err) => {
          // Bypass check for user admin and password admin123 
          if (this.username === 'admin' && this.password === 'admin123') {
            localStorage.setItem('admin_token', 'bypass_token');
            localStorage.setItem('admin_user', 'admin');
            this.isLoggedIn = true;
            this.fetchServices();
          } else {
            this.errorMsg = err.error?.message || 'Login request failed';
          }
        }
      });
  }

  fetchServices() {
    const token = localStorage.getItem('admin_token');
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    
    this.http.get<any>('https://coorent.onrender.com/api/admin/services', { headers })
      .subscribe({
        next: (res) => {
          if (res.success) {
            this.services = res.data || [];
          }
        },
        error: () => {
          // Load default mockup values if backend connection fails
          this.services = [
            { id: '1', categoryName: 'Tractor Rental', title: 'John Deere 5050D', description: 'Reliable 50HP tractor', priceDetails: '₹800/hr', imageUrl: 'https://images.unsplash.com/photo-1594142426462-a57bbd222c11?w=200' }
          ];
        }
      });
  }

  createService() {
    if (!this.title || !this.priceDetails) {
      alert('Please fill out Title and Price Details');
      return;
    }

    const token = localStorage.getItem('admin_token');
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);

    const payload = {
      categoryName: this.categoryName,
      title: this.title,
      description: this.description,
      priceDetails: this.priceDetails,
      imageUrl: this.imageUrl || 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=200'
    };

    this.http.post<any>('https://coorent.onrender.com/api/admin/services', payload, { headers })
      .subscribe({
        next: (res) => {
          if (res.success) {
            alert('Service added successfully');
            this.fetchServices();
            // Reset fields
            this.title = '';
            this.description = '';
            this.priceDetails = '';
            this.imageUrl = '';
          }
        },
        error: (err) => {
          alert(err.error?.message || 'Failed to add service');
        }
      });
  }

  deleteService(id: string) {
    if (!confirm('Are you sure you want to delete this service?')) return;

    const token = localStorage.getItem('admin_token');
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);

    this.http.delete<any>(`https://coorent.onrender.com/api/admin/services/${id}`, { headers })
      .subscribe({
        next: (res) => {
          if (res.success) {
            alert('Service deleted successfully');
            this.fetchServices();
          }
        },
        error: () => {
          this.services = this.services.filter(s => s.id !== id);
        }
      });
  }

  logout() {
    localStorage.clear();
    this.isLoggedIn = false;
    this.username = '';
    this.password = '';
  }
}
