import Button from '@/components/ui/button/button';

export const MainErrorFallback = () => {
    return (
        <div
            role="alert"
        >
            <h2>Oops, something went wrong!</h2>
            <Button
                onClick={() => window.location.assign(window.location.origin)}
            >
                Refresh
            </Button>
        </div>
    );
};