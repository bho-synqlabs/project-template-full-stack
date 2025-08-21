import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense, useState } from "react";
import { ErrorBoundary } from 'react-error-boundary';
import { queryConfig } from "@/lib/react-query";
import { MainErrorFallback } from "@/components/errors/main";

type AppProviderProps = {
    children: React.ReactNode;
};

export const AppProvider = ({ children }: AppProviderProps) => {
    const [queryClient] = useState(
        () =>
            new QueryClient({
                defaultOptions: queryConfig,
            }),
    );

    return (
        <Suspense fallback={<div>Loading...</div>}>
            <ErrorBoundary FallbackComponent={MainErrorFallback}>
                <QueryClientProvider client={queryClient}>
                    {children}
                </QueryClientProvider>
            </ErrorBoundary>
        </Suspense >
    );
}