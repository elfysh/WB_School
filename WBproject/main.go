package main

import (
	"bytes"
	"context"
	"encoding/json"
	"golang.org/x/time/rate"
	"log"
	"math/rand"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/joho/godotenv"
)

var (
	serverLimiter = rate.NewLimiter(5, 5)
	serverStats   = struct {
		sync.Mutex
		stats map[int]int
	}{stats: make(map[int]int)}
	clientStats = struct {
		sync.Mutex
		stats map[string]map[int]int
	}{stats: make(map[string]map[int]int)}
)

func handler(w http.ResponseWriter, r *http.Request) {
	if !serverLimiter.Allow() {
		http.Error(w, "Лимит запросов превышен", http.StatusTooManyRequests)
		return
	}

	switch r.Method {
	case http.MethodGet:
		serverStats.Lock()
		clientStats.Lock()
		data, _ := json.Marshal(map[string]interface{}{
			"server":  serverStats.stats,
			"clients": clientStats.stats,
		})
		clientStats.Unlock()
		serverStats.Unlock()
		w.Header().Set("Content-Type", "application/json")
		w.Write(data)
	case http.MethodPost:
		status := getRandomStatus()
		serverStats.Lock()
		serverStats.stats[status]++
		serverStats.Unlock()
		client := r.Header.Get("Client-ID")
		if client != "" {
			clientStats.Lock()
			if _, exists := clientStats.stats[client]; !exists {
				clientStats.stats[client] = make(map[int]int)
			}
			clientStats.stats[client][status]++
			clientStats.Unlock()
		}
		w.WriteHeader(status)
		w.Write([]byte(http.StatusText(status)))
	default:
		http.Error(w, "Метод не поддерживается", http.StatusMethodNotAllowed)
	}
}

func getRandomStatus() int {
	if rand.Intn(100) < 70 {
		if rand.Intn(2) == 0 {
			return http.StatusOK
		}
		return http.StatusAccepted
	} else {
		if rand.Intn(2) == 0 {
			return http.StatusBadRequest
		}
		return http.StatusInternalServerError
	}
}

type Client struct {
	id      string
	url     string
	workers int
	sync.Mutex
	stats   map[int]int
	limiter *rate.Limiter
}

func (c *Client) sendRequest(wg *sync.WaitGroup) {
	defer wg.Done()
	for i := 0; i < 50; i++ {
		c.limiter.Wait(context.Background())
		req, _ := http.NewRequest(http.MethodPost, c.url, bytes.NewBuffer([]byte(`{"message": "hello"}`)))
		req.Header.Set("Client-ID", c.id)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			log.Println("Ошибка POST запроса:", err)
			continue
		}
		c.Lock()
		c.stats[resp.StatusCode]++
		c.Unlock()
		resp.Body.Close()
	}
}

func (c *Client) startClient(wg *sync.WaitGroup) {
	defer wg.Done()
	var workerWG sync.WaitGroup
	for i := 0; i < c.workers; i++ {
		workerWG.Add(1)
		go c.sendRequest(&workerWG)
	}
	workerWG.Wait()
	c.printStats()
}

func (c *Client) printStats() {
	log.Printf("Клиент %s завершил отправку запросов. Статистика:", c.id)
	totalRequests := 0
	for status, count := range c.stats {
		totalRequests += count
		log.Printf("%d - %d", status, count)
	}
	log.Printf("Отправлено запросов: %d", totalRequests)
}

func clientCheckServer(url string) {
	for {
		resp, err := http.Get(url)
		if err != nil {
			log.Println("Сервер недоступен")
		} else {
			log.Println("Сервер доступен")
			resp.Body.Close()
		}
		time.Sleep(5 * time.Second)
	}
}

func saveStatsToFile() {
	serverStats.Lock()
	clientStats.Lock()
	data, _ := json.MarshalIndent(map[string]interface{}{
		"server":  serverStats.stats,
		"clients": clientStats.stats,
	}, "", "  ")
	clientStats.Unlock()
	serverStats.Unlock()
	os.WriteFile("server_stats.json", data, 0644)
}

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("Нет .env файла, используем стандартные переменные окружения")
	}

	port := os.Getenv("PORT")
	if port == "" {
		log.Fatal("PORT не задан в файле .env")
	}

	rand.Seed(time.Now().UnixNano())
	http.HandleFunc("/", handler)

	serverReady := make(chan struct{})
	go func() {
		log.Printf("Сервер запущен на порту %s", port)
		close(serverReady)
		if err := http.ListenAndServe(":"+port, nil); err != nil {
			log.Fatal("Ошибка запуска сервера: ", err)
		}
	}()

	<-serverReady
	time.Sleep(1 * time.Second)

	url := "http://localhost:" + port
	var wg sync.WaitGroup

	client1 := &Client{id: "client1", url: url, workers: 2, stats: make(map[int]int), limiter: rate.NewLimiter(5, 5)}
	client2 := &Client{id: "client2", url: url, workers: 2, stats: make(map[int]int), limiter: rate.NewLimiter(5, 5)}

	wg.Add(2)
	go client1.startClient(&wg)
	go client2.startClient(&wg)
	go clientCheckServer(url)

	wg.Wait()
	saveStatsToFile()
}
