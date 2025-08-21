import { forwardRef } from 'react';

export type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement>;

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
	({ className, children, ...props }, ref) => {
		return (
			<button className={className} ref={ref} {...props}>
				{children}
			</button>
		);
	},
);

Button.displayName = 'Button';

export default Button;
