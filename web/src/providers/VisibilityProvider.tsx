import React, {
	Context,
	createContext,
	useContext,
	useEffect,
	useState,
} from "react";
import { useNuiEvent, fetchNui } from "../utils/utils";
import { isEnvBrowser } from "../utils/misc";

const VisibilityCtx = createContext<VisibilityProviderValue | null>(null);

interface VisibilityProviderValue {
	setVisible: (visible: boolean) => void;
	visible: boolean;
}

// This should be mounted at the top level of your application, it is currently set to
// apply a CSS visibility value. If this is non-performant, this should be customized.
export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({
	children,
}) => {
	const [visible, setVisible] = useState(false);

	useNuiEvent<boolean>("setVisible", setVisible);

	// Handle pressing escape/backspace
	useEffect(() => {
		// Only attach listener when we are visible
		if (!visible) return;

		const keyHandler = (e: KeyboardEvent) => {
			if (e.code === "Escape") {
				fetchNui("exit");
			}
		};

		const contextMenuHandler = (e: MouseEvent) => {
			e.preventDefault();
			fetchNui("exit");
		};

		window.addEventListener("keydown", keyHandler);
		window.addEventListener("contextmenu", contextMenuHandler);

		return () => {
			window.removeEventListener("keydown", keyHandler);
			window.removeEventListener("contextmenu", contextMenuHandler);
		};
	}, [visible]);

	return (
		<VisibilityCtx.Provider
			value={{
				visible,
				setVisible,
			}}
		>
			<div
				style={{ visibility: visible ? "visible" : "hidden", height: "100%" }}
			>
				{children}
			</div>
		</VisibilityCtx.Provider>
	);
};

export const useVisibility = () =>
	useContext<VisibilityProviderValue>(
		VisibilityCtx as Context<VisibilityProviderValue>
	);
