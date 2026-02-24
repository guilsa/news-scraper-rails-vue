import { useState, useEffect } from 'react'
import ArticleList from '@components/ArticleList'
import { useFetch } from '@hooks/useFetch'
import { type Article } from '@/types/article'
import '@styles/App.css'

function App() {
  const [articles, setArticles] = useState<Article[]>([])
  const [page, setPage] = useState(1)

  const params = new URLSearchParams({
    page: page.toString(),
    limit: '50',
  })

  const { status, data, error } = useFetch<Article[]>(`/articles?${params.toString()}`)

  useEffect(() => {
    if (status !== 'fetched' || !Array.isArray(data) || data.length === 0) return
    setArticles((oldArticles) => [...oldArticles, ...data])
  }, [status, data])

  useEffect(() => {
    if (status === 'fetching') return

    function handleScroll() {
      if (window.innerHeight + window.scrollY >= document.body.offsetHeight) {
        setPage((prev) => prev + 1)
      }
    }

    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [status])

  return (
    <main>
      <header>updated: {new Date().toLocaleString()}</header>

      <section>
        {status === 'error' && <div>{error}</div>}
        {status === 'fetching' && <span>Loading.....</span>}
        <ArticleList data={articles} />
      </section>
    </main>
  )
}

export default App
