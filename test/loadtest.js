import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 50,
  duration: '5m',
};

export default function () {
  // ALB_DNS_NAME will be replaced during deployment
  const BASE_URL = 'http://ALB_DNS_NAME';
  
  http.get(`${BASE_URL}/`);     // web frontend
  http.get(`${BASE_URL}/cats`); // cats service
  http.get(`${BASE_URL}/dogs`); // dogs service
  sleep(0.5);
}