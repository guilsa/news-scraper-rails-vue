import { useEffect, useRef, useReducer } from 'react'

const BASE_URL = '/api/v1'

type FetchState<T> = {
  status: 'idle' | 'fetching' | 'fetched' | 'error'
  error: string | null
  data: T | null
}

type FetchAction<T> =
  | { type: 'FETCHING' }
  | { type: 'FETCHED'; payload: T }
  | { type: 'FETCH_ERROR'; payload: string }

export function useFetch<T>(url: string): FetchState<T> {
  const cache = useRef<Record<string, T>>({})

  const initialState: FetchState<T> = {
    status: 'idle',
    error: null,
    data: null,
  }

  const [state, dispatch] = useReducer(
    (state: FetchState<T>, action: FetchAction<T>): FetchState<T> => {
      switch (action.type) {
        case 'FETCHING':
          return { ...initialState, status: 'fetching' }
        case 'FETCHED':
          return { ...initialState, status: 'fetched', data: action.payload }
        case 'FETCH_ERROR':
          return { ...initialState, status: 'error', error: action.payload }
        default:
          return state
      }
    },
    initialState
  )

  useEffect(() => {
    let cancelRequest = false
    if (!url) return

    const fetchData = async () => {
      dispatch({ type: 'FETCHING' })
      if (cache.current[url]) {
        const data = cache.current[url]
        dispatch({ type: 'FETCHED', payload: data })
      } else {
        try {
          const response = await fetch(BASE_URL + url)
          const data = await response.json()
          cache.current[url] = data
          if (cancelRequest) return
          dispatch({ type: 'FETCHED', payload: data })
        } catch (error) {
          if (cancelRequest) return
          dispatch({ type: 'FETCH_ERROR', payload: (error as Error).message })
        }
      }
    }

    fetchData()

    return () => {
      cancelRequest = true
    }
  }, [url])

  return state
}
