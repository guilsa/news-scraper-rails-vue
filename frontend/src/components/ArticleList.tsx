import dayjs from 'dayjs'
import { type Article as ArticleType } from '@/types/article'
import '@styles/Article.css'

type ArticleProps = {
  source: string
  bias_rating?: string
  url: string
  title: string
  description: string
  citations_amount?: number
}

function displayBiasRating(bias_rating?: string) {
  if (!bias_rating) return null
  return <>({bias_rating})</>
}

function displayTotalCitations(totalCitations?: number) {
  if (!totalCitations) return null
  return <span>({totalCitations})</span>
}

function Article({ source, bias_rating, url, title, description, citations_amount }: ArticleProps) {
  return (
    <article className="container">
      <div className="publication-name">
        <span>{source}</span>
        <span className="capitalize">&nbsp;{displayBiasRating(bias_rating)}</span>
      </div>
      <div className="title-description">
        <h3>
          <a href={url}>{title}</a>
        </h3>
        <p>{description}</p>
        {displayTotalCitations(citations_amount)}
      </div>
    </article>
  )
}

type ArticleListProps = {
  data: ArticleType[]
}

export default function ArticleList({ data }: ArticleListProps) {
  const groupedByDate = data?.reduce((acc, article) => {
    const date = article.date
    if (!acc[date]) {
      acc[date] = []
    }
    acc[date].push(article)
    return acc
  }, {} as Record<string, ArticleType[]>)

  return (
    <>
      {Object.entries(groupedByDate || {}).map(([date, articles]) => (
        <div key={date}>
          <div className="date">{dayjs(date).format('MM/DD/YYYY')}</div>
          {articles.map((article) => (
            <Article
              key={article.id}
              source={article.source}
              url={article.url}
              title={article.title}
              description={article.description}
              citations_amount={article.citations_amount}
              bias_rating={article.bias_rating}
            />
          ))}
        </div>
      ))}
    </>
  )
}
