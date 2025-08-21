export const paths = {
	home: {
		path: '/',
		getHref: () => '/',
	},
	auth: {
		register: {
			getHref: (redirectTo?: string | null | undefined) =>
				`/auth/register${
					redirectTo ? `?redirectTo=${encodeURIComponent(redirectTo)}` : ''
				}`,
		},
		login: {
			getHref: (redirectTo?: string | null | undefined) =>
				`/auth/login${
					redirectTo ? `?redirectTo=${encodeURIComponent(redirectTo)}` : ''
				}`,
		},
	},
};
